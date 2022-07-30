<?php
namespace App\Models;

use CodeIgniter\Model;

class Flow_model extends Model {

	public function register_flow_to_company($flow){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow');
        $builder->insert($flow);
	}

	public function get_flow_from_flow_id($flow_id){
		$db = db_connect();
        $builder = $db->table('t_flow');
        $builder->select("*");
        $builder->where("id", $flow_id);
        $query = $builder->get();
        return $query->getRowArray();
	}

	public function get_flow_from_flow_name($flow_name){
		$db = db_connect();
        $builder = $db->table('t_flow');
        $builder->select("*");
		$builder->where("name",$flow_name);
        $query = $builder->get();
        return $query->getRowArray();
	}

	public function get_flowname_list(){
		$db = db_connect();
        $builder = $db->table('t_flow');
        $builder->select("*");
		$builder->where('active',1);
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function get_flowtype_list(){
		$db = db_connect();
        $builder = $db->table('t_flow_type');
        $builder->select("*");
		$builder->where('active',1);
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function get_flowfamily_list(){
		$db = db_connect();
        $builder = $db->table('t_flow_family');
        $builder->select("*");
		$builder->where('active',1);
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function get_company_flow_list($companyID){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow');
        $builder->select('*,t_flow_family.name as flowfamily,t_cmpny_flow.id as id,t_flow.name as flowname,t_flow_type.name  as flowtype,t_cmpny_flow.id as cmpny_flow_id,t_cmpny_flow.qntty as qntty,unit1.name as qntty_unit_name,t_cmpny_flow.cost as cost,t_cmpny_flow.ep as ep,t_cmpny_flow.ep_unit_id as ep_unit, t_cmpny_flow.cost_unit_id as cost_unit');
        $builder->join('t_flow','t_flow.id = t_cmpny_flow.flow_id');
		$builder->join('t_flow_family','t_flow.flow_family_id = t_flow_family.id', 'left');
		$builder->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id');
		$builder->join('t_unit as unit1','unit1.id = t_cmpny_flow.qntty_unit_id');
        $builder->where('cmpny_id',$companyID);
        $builder->orderBy("t_flow.name", "asc");
		$builder->orderBy("t_flow_type.name", "asc");
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function get_company_flow($companyID,$flow_id,$flow_type_id){

		$db = db_connect();
        $builder = $db->table('t_cmpny_flow');
        $builder->select('*,t_flow_family.name as flowfamily,t_cmpny_flow.id as id,t_flow.name as flowname,t_flow_type.name  as flowtype,t_cmpny_flow.id as cmpny_flow_id,t_cmpny_flow.qntty as qntty,unit1.name as qntty_unit_name,t_cmpny_flow.cost as cost,t_cmpny_flow.ep as ep,t_cmpny_flow.ep_unit_id as ep_unit, t_cmpny_flow.cost_unit_id as cost_unit');
        $builder->join('t_flow','t_flow.id = t_cmpny_flow.flow_id');
		$builder->join('t_flow_family','t_flow.flow_family_id = t_flow_family.id', 'left');
		$builder->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id');
		$builder->join('t_unit as unit1','unit1.id = t_cmpny_flow.qntty_unit_id');
		$builder->where('cmpny_id',$companyID);
		$builder->where('flow_id',$flow_id);
		$builder->where('flow_type_id',$flow_type_id);
        $query = $builder->get();
        return $query->getRowArray();
	}

	public function get_unit_list(){
		$db = db_connect();
        $builder = $db->table('t_unit');
        $builder->select("*");
		$builder->where('active',1);
		$builder->orderBy("id", "asc");
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function has_same_flow($flow_id,$flow_type_id,$companyID){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow');
        $builder->select("*");
		$builder->where('flow_id',$flow_id);
		$builder->where('flow_type_id',$flow_type_id);
		$builder->where('cmpny_id',$companyID);
        $query = $builder->get()->getResultArray();
		if(!empty($query)){
			return false;
		}
		else{
			return true;
		}
	}

	public function delete_flow($id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow');
		$builder->where('id', $id);
        $builder->delete();
	}

	public function update_flow_info($companyID,$flow_id,$flow_type_id,$flow){
		$db = db_connect();
		$builder = $db->table('t_cmpny_flow');
		$builder->where('t_cmpny_flow.cmpny_id',$companyID);
	    $builder->where('t_cmpny_flow.flow_id',$flow_id);
	    $builder->where('t_cmpny_flow.flow_type_id',$flow_type_id); 
		$builder->replace($flow);
	}

	public function set_userep($data){
		$db = db_connect();
        $builder = $db->table('t_user_ep_values');
        $builder->insert($data);
	}

	public function delete_userep($flow_name,$ep_value,$user_id){
		$db = db_connect();
        $builder = $db->table('t_user_ep_values');
        $builder->where('user_id', $user_id);
		$builder->where('ep_value', $ep_value);
		$builder->where('flow_name', $flow_name);
        $builder->delete();
	}

	// gets flow ep values from excel imported data based on given userid.
	public function get_userep($userid){
		$db = db_connect();
        $builder = $db->table('t_user_ep_values');
        $builder->select("*,unit1.name as qntty_unit_name");
		$builder->join('t_unit as unit1','unit1.id = t_user_ep_values.ep_q_unit');
        $builder->where('user_id',$userid);
        $query = $builder->get();
        return $query->getResultArray();
	}
	
	// gets flow ep values from excel imported data based on given flowname and userid.
	public function get_My_Ep_Values($flowname,$userid){
		$db = db_connect();
        $builder = $db->table('t_user_ep_values');
        $builder->select("*,unit1.name as qntty_unit_name");
		$builder->join('t_unit as unit1','unit1.id = t_user_ep_values.ep_q_unit');
        $builder->where('user_id',$userid);
        $builder->where('flow_name',$flowname);
        $query = $builder->get();
        return $query->getResultArray();
	}

}