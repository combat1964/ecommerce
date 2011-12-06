<?php

/**
 * Option
 *
 * @author Pavel Kovalyov <pavlo.kovalyov@gmail.com>
 */
class Models_Mapper_OptionMapper extends Application_Model_Mappers_Abstract {

	protected $_model = 'Models_Model_Option';
	
	protected $_dbTable = 'Models_DbTable_Option';

    /**
     * Method saves model to DB
     * @param $model Models_Model_Option
     * @return Models_Model_Option
     */
	public function save($model){
		if (! $model instanceof  $this->_model){
			$model = new $this->_model($model);
		}
		
		$data = array(
			'title'     => $model->getTitle(),
			'type'	    => $model->getType(),
            'parentId'  => $model->getParentId()
		);
		
		if ($model->getId()){
			$where = $this->getDbTable()->getAdapter()->quoteInto('id = ?', $model->getId());
			$result = $this->getDbTable()->update($data, $where);
		} else {
			$id = $this->getDbTable()->insert($data);
			$model->setId($id);
		}

		if ($model->getSelection()){
			$this->_proccessSelection($model);
		}
		
		return $model;
	}
	
	public function find($id) {
		if (is_array($id) && !empty ($id)){
			foreach ($id as $i) {
				$this->find($i);
			}
		}
		
		$result = $this->getDbTable()->find($id);
		if(0 == count($result)) {
			return null;
		}
		$row = $result->current();
		$model = new $this->_model($row->toArray());
		
		if ($model->getType() === $model::TYPE_DROPDOWN || $model->getType() === $model::TYPE_RADIO) {
//			$selections = $row->findDependentRowset('Models_DbTable_Selection', 'Models_DbTable_OptionSelection');
			$selections = $row->findDependentRowset('Models_DbTable_Selection');
			if ($selections->count()){
				$model->setSelection($selections->toArray());
			}
		}

        if ($model->getParentId()){

        }
		
		return $model;
	}

	private function _proccessSelection(Models_Model_Option $model){
		$selectionTable = new Models_DbTable_Selection();
		$selectionTable->getAdapter()->beginTransaction();

        $selectionList = $model->getSelection();
		foreach ($selectionList as $item) {
			$data = array(
				'option_id'		=> $model->getId(),
				'title'			=> $item['title'],
				'priceSign'		=> $item['priceSign'],
				'priceValue'	=> $item['priceValue'],
				'priceType'		=> $item['priceType'],
				'weightValue'	=> $item['weightValue'],
				'weightSign'	=> $item['weightSign'],
				'isDefault'		=> $item['isDefault']
			);
			if (isset($item['id'])) {
				$where = $selectionTable->getAdapter()->quoteInto('id = ?', $item['id']);
				if (isset($item['_deleted']) && $item['_deleted'] == true){
					$selectionTable->delete($where);
					continue;
				}
				$selectionTable->update($data, $where);
			} else {
				$selectionTable->insert($data);
			}
		}
		
		return $selectionTable->getAdapter()->commit();
	}
}