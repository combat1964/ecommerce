<?php
/**
 * Tools_Shipping_Plugin
 * @author Pavel Kovalyov <pavlo.kovalyov@gmail.com>
 */
class Tools_Shipping_Plugin extends Tools_Plugins_Abstract implements Interfaces_Shipping {

	protected function _init(){
		$this->_jsonHelper = Zend_Controller_Action_HelperBroker::getExistingHelper('json');
		$this->_shoppingConfig = Models_Mapper_ShoppingConfig::getInstance()->getConfigParams();
	}

	/**
	 * Internal method that stores calculated rates in user session
	 * Need to make possible to apply user choosen method and prevent cheating from frontend.
	 * @param $rates array List of calculated rates per service
	 * @return Tools_Shipping_Plugin Returns self for chaining support
	 */
	protected function _storeRates($rates){
		$vault = $this->_sessionHelper->shippingRatesVault;
		if (!$vault){
			$vault = array();
		}
		$shipperName = strtolower(get_called_class());
		$vault[$shipperName] = $rates;

		$this->_sessionHelper->shippingRatesVault = $vault;

		return $this;
	}

	/**
	 * Method that called from checkout process to calculate rates
	 * Should implements main calculation and/or remote API calls
	 * @return JSON collection of available shipping methods
	 */
	public function calculateAction(){}

	/**
	 * Method that returns config form for shipper for GET request and
	 * process config form submitted via POST request
	 */
	public function configAction(){}
}
