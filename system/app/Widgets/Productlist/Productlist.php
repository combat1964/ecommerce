<?php

class Widgets_Productlist_Productlist extends Widgets_Abstract {

	/**
	 * Suboption for the categories
	 */
	const OPTTYPE_CATEGORIES    = 'categories';

	/**
	 *  Suboption for the brands
	 */
	const OPTTYPE_BRANDS        = 'brands';

	/**
	 * Suboption for the order
	 */
	const OPTTYPE_ORDER         = 'order';

	protected $_configHelper    = null;

	protected $_websiteHelper   = null;

	protected $_productMapper   = null;

	protected $_renderedContent = '';

	protected $_themeConfig     = null;

	protected $_template        = null;

	protected $_orderSequence   = array();

	public function _init() {
		parent::_init();
		if (empty($this->_options)){
			throw new Exceptions_SeotoasterWidgetException('No options provided');
		}
		$this->_view = new Zend_View(array(
			'scriptPath' => dirname(__FILE__) . '/views'
		));
		$this->_websiteHelper    = Zend_Controller_Action_HelperBroker::getExistingHelper('website');
	    $this->_configHelper     = Zend_Controller_Action_HelperBroker::getExistingHelper('config');
	    $this->_view->websiteUrl = $this->_websiteHelper->getUrl();
		$this->_themeConfig      = Zend_Registry::get('theme');
		$this->_productMapper    = Models_Mapper_ProductMapper::getInstance();

	}

	public function _load() {
		$this->_template = Application_Model_Mappers_TemplateMapper::getInstance()->findByName(array_shift($this->_options));
		if($this->_template === null) {
			throw new Exceptions_SeotoasterWidgetException('Product template doesn\'t exist');
		}
		$products = $this->_prepareProducts();
		if(!empty($products)) {
			array_walk($products, array($this, '_parsingCallback'));
			return $this->_renderedContent;
		}
		return '';
	}

	private function _parsingCallback($product) {
		$parser = new Tools_Content_Parser(
			$this->_template->getContent(),
			$product->getPage()->toArray(),
			array(
	            'websiteUrl'   => $this->_websiteHelper->getUrl(),
	            'websitePath'  => $this->_websiteHelper->getPath(),
	            'currentTheme' => $this->_configHelper->getConfig('currentTheme'),
	            'themePath'    => $this->_themeConfig['path']
	        )
		);
		$this->_renderedContent .= $parser->parse();
		unset($parser);
	}

	private function _prepareProducts() {
		$products = array();
		if(empty($this->_options)) {
			return $this->_productMapper->fetchAll();
		}
		foreach($this->_options as $option) {
			if(false === ($optData = $this->_processOption($option))) {
				continue;
			}
			switch($optData['type']) {
				case self::OPTTYPE_CATEGORIES:
					$products = $this->_productMapper->findByCategories($optData['values']);
				break;
				case self::OPTTYPE_BRANDS:
					if(empty($products)) {
						$products = $this->_productMapper->findByBrands($optData['values']);
					}
					foreach($products as $key => $product) {
						if(!in_array($product->getBrand(), $optData['values'])) {
							unset($products[$key]);
						}
					}
				break;
				case self::OPTTYPE_ORDER:
					if(empty($products)) {
						$products = $this->_productMapper->fetchAll();
					}
					$this->_orderSequence = $optData['values'];
					$products             = $this->_sort($products);
				break;
			}
		}
		return $products;
	}

	/**
	 * Takes an option from the options array and find the specific constructions
	 *
	 * such as categories-id1,id2,idn; brands-name1,name2,namen, order-name,brand,price
	 * and makes an array array('type' => 'categories', 'values' => 'id1,id2,idn')
	 *
	 * @param $option string
	 * @return mixed
	 */
	private function _processOption($option) {
		$exploded = explode('-', $option);
		if(sizeof($exploded) != 2) {
			return false;
		}
		return array(
			'type'   => $exploded[0],
			'values' => explode(',', $exploded[1])
		);
	}

	private function _sort($products) {
		uasort($products, array($this, '_sortingCallback'));
		return $products;
	}

	private function _sortingCallback($productOne, $productTwo) {
		if($this->_orderSequence) {
			$compareResult = 0;
			foreach($this->_orderSequence as $orderTerm) {
				$getter = 'get' . ucfirst($orderTerm);
				if(!method_exists($productOne, $getter) || !method_exists($productTwo, $getter)) {
					continue;
				}
				$productOneTerm = $productOne->$getter();
				$productTwoTerm = $productTwo->$getter();
				if(is_integer($productOneTerm) && is_integer($productTwoTerm)) {
					$compareResult = ($productOneTerm - $productTwoTerm) ? ($productOneTerm - $productTwoTerm) / abs($productOneTerm - $productTwoTerm) : 0;
					if($compareResult !== 0) {
						return $compareResult;
					}
				}
				else {
					$compareResult = strcasecmp($productOneTerm, $productTwoTerm);
					if($compareResult !== 0) {
						return $compareResult;
					}
				}
			}
			return $compareResult;
		}
	}
}