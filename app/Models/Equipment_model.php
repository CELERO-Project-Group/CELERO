<?php
namespace App\Models;

use CodeIgniter\Model;

class Equipment_model extends Model {

	public function get_equipment_name(){
		$db = db_connect();
		$builder = $db->table('t_eqpmnt');
		$builder->select('*');
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function cmpny_prcss($id){
		$db = db_connect();
		$builder = $db->table('t_cmpny_prcss');
		$builder->select('t_prcss.name as prcessname,t_prcss.id as processid');
		$builder->join('t_prcss','t_cmpny_prcss.prcss_id = t_prcss.id');
		$builder->where('t_cmpny_prcss.cmpny_id',$id);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function get_cmpny_process($id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
        $builder->select('t_cmpny_prcss.id');
		$builder->where('t_cmpny_prcss.prcss_id',$id);
        $query = $builder->get();
        return $query->getRowArray();
	}

	public function get_equipment_type_list($equipment_id){
		$db = db_connect();
		$builder = $db->table('t_eqpmnt_type');
		$builder->select('id,name');
		$builder->where('mother_id',$equipment_id);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function get_equipment_attribute_list($equipment_type_id){
		$db = db_connect();
		$builder = $db->table('t_eqpmnt_type_attrbt');
		$builder->select('id,attribute_name');
		$builder->where('eqpmnt_type_id',$equipment_type_id);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function set_info($data){  
		$db = db_connect();
        $builder = $db->table('t_cmpny_eqpmnt');
        $builder->insert($data);
        return $db->insertID();
	}

	public function all_information_of_equipment($companyID){
		$db = db_connect();
		$builder = $db->table('t_cmpny_prcss_eqpmnt_type');
		$builder->select('t_cmpny.name as fathername, t_cmpny_eqpmnt.cmpny_id as companyfatherid, t_cmpny_eqpmnt.eqpmnt_attrbt_val,t_cmpny_eqpmnt.id as cmpny_eqpmnt_id, t_eqpmnt.name as eqpmnt_name, t_eqpmnt_type.name as eqpmnt_type_name, t_eqpmnt_type_attrbt.attribute_name as eqpmnt_type_attrbt_name, t_prcss.name as prcss_name,unit1.name as unit');
		$builder->join('t_cmpny_eqpmnt','t_cmpny_eqpmnt.id = t_cmpny_prcss_eqpmnt_type.cmpny_eqpmnt_type_id','left');
		$builder->join('t_eqpmnt','t_eqpmnt.id = t_cmpny_eqpmnt.eqpmnt_id','left');
		$builder->join('t_eqpmnt_type','t_eqpmnt_type.id = t_cmpny_eqpmnt.eqpmnt_type_id','left');
		$builder->join('t_eqpmnt_type_attrbt','t_eqpmnt_type_attrbt.id = t_cmpny_eqpmnt.eqpmnt_type_attrbt_id','left');
		$builder->join('t_cmpny_prcss','t_cmpny_prcss.id = t_cmpny_prcss_eqpmnt_type.cmpny_prcss_id','left');
		$builder->join('t_prcss','t_prcss.id = t_cmpny_prcss.prcss_id','left');
		$builder->join('t_unit as unit1','unit1.id = t_cmpny_eqpmnt.eqpmnt_attrbt_unit','left');
		$builder->join('t_cmpny', 't_cmpny.id = t_cmpny_eqpmnt.cmpny_id','left');
		$builder->where('t_cmpny_eqpmnt.cmpny_id',$companyID);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function get_cmpny_prcss_id($companyID,$prcss_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss');
        $builder->select('id');
        $builder->where('cmpny_id',$companyID);
		$builder->where('prcss_id',$prcss_id);
        $query = $builder->get();
        return $query->getRowArray();
	}

	public function set_cmpny_prcss($data){
		$db = db_connect();
        $builder = $db->table('t_cmpny_prcss_eqpmnt_type');
        $builder->insert($data);
	}

	public function delete_cmpny_equipment($cmpny_prcss_id){
		$db = db_connect();        
        $builder = $db->table('t_cmpny_prcss_eqpmnt_type');
		$builder->where('cmpny_prcss_id', $cmpny_prcss_id);
        $builder->delete();
	}

	public function delete_cmpny_prcss_eqpmnt_type($cmpny_eqpmnt_id){
		$db = db_connect();        
        $builder = $db->table('t_cmpny_prcss_eqpmnt_type');
		$builder->where('cmpny_eqpmnt_type_id', $cmpny_eqpmnt_id);
        $builder->delete();
	}

	public function delete_cmpny_eqpmnt($id){
		$db = db_connect();        
        $builder = $db->table('t_cmpny_eqpmnt');
		$builder->where('id', $id);
        $builder->delete();
	}
}
?>
