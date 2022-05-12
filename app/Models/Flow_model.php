<?php
namespace App\Models;

use CodeIgniter\Model;

class Flow_model extends Model {

	public function __construct()
	{
		$db = db_connect();
	}

	public function register_flow_to_company($flow){
		$db->insert('t_cmpny_flow', $flow);
	}

	public function get_flow_from_flow_id($flow_id){
		$db->select("*");
		$db->from("t_flow");
		$db->where("id",$flow_id);
		$query = $db->get();
		return $query->row_array();
	}

	public function get_flow_from_flow_name($flow_name){
		$db->select("*");
		$db->from("t_flow");
		$db->where("name",$flow_name);
		$query = $db->get();
		return $query->row_array();
	}

	public function get_flowname_list(){
		$db->select("*");
		$db->from("t_flow");
		$db->where('active',1);
		$query = $db->get();
		return $$query->getResultArray();
	}

	public function get_flowtype_list(){
		$db->select("*");
		$db->from("t_flow_type");
		$db->where('active',1);
		$query = $db->get();
		return $$query->getResultArray();
	}

	public function get_flowfamily_list(){
		$db->select("*");
		$db->from("t_flow_family");
		$db->where('active',1);
		$query = $db->get();
		return $$query->getResultArray();
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
		$db->select('*,t_flow_family.name as flowfamily,t_cmpny_flow.id as id,t_flow.name as flowname,t_flow_type.name  as flowtype,t_cmpny_flow.id as cmpny_flow_id,t_cmpny_flow.qntty as qntty,unit1.name as qntty_unit_name,t_cmpny_flow.cost as cost,t_cmpny_flow.ep as ep,t_cmpny_flow.ep_unit_id as ep_unit, t_cmpny_flow.cost_unit_id as cost_unit');
		$db->from("t_cmpny_flow");
		$db->join('t_flow','t_flow.id = t_cmpny_flow.flow_id');
		$db->join('t_flow_family','t_flow.flow_family_id = t_flow_family.id', 'left');
		$db->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id');
		$db->join('t_unit as unit1','unit1.id = t_cmpny_flow.qntty_unit_id');
		$db->where('cmpny_id',$companyID);
		$db->where('flow_id',$flow_id);
		$db->where('flow_type_id',$flow_type_id);
		$query = $db->get();
		return $query->row_array();
	}

	public function get_unit_list(){
		$db->select("*");
		$db->from("t_unit");
		$db->where('active',1);
		$db->order_by("id", "asc");
		$query = $db->get();
		return $$query->getResultArray();
	}

	public function has_same_flow($flow_id,$flow_type_id,$companyID){
		$db->select("*");
		$db->from("t_cmpny_flow");
		$db->where('flow_id',$flow_id);
		$db->where('flow_type_id',$flow_type_id);
		$db->where('cmpny_id',$companyID);
		$query = $db->get()->result_array();
		if(!empty($query)){
			return false;
		}
		else{
			return true;
		}
	}

	public function delete_flow($id){
		$db->where('id', $id);
		$db->delete('t_cmpny_flow');
	}

	public function update_flow_info($companyID,$flow_id,$flow_type_id,$flow){
	    $db->where('t_cmpny_flow.cmpny_id',$companyID);
	    $db->where('t_cmpny_flow.flow_id',$flow_id);
	    $db->where('t_cmpny_flow.flow_type_id',$flow_type_id);
	    $db->update('t_cmpny_flow',$flow);
	}

	public function set_userep($data){
		$db->insert('t_user_ep_values',$data);
	}

	public function delete_userep($flow_name,$ep_value,$user_id){
		$db->where('user_id', $user_id);
		$db->where('ep_value', $ep_value);
		$db->where('flow_name', $flow_name);
		$db->delete('t_user_ep_values');
	}

	// gets flow ep values from excel imported data based on given userid.
	public function get_userep($userid){
        $db->select("*,unit1.name as qntty_unit_name");
		$db->from("t_user_ep_values");
		$db->join('t_unit as unit1','unit1.id = t_user_ep_values.ep_q_unit');
        $db->where('user_id',$userid);
        $query = $db->get();
        return $$query->getResultArray();
	}
	
	// gets flow ep values from excel imported data based on given flowname and userid.
	public function get_My_Ep_Values($flowname,$userid){
		$db->select("*,unit1.name as qntty_unit_name");
		$db->from("t_user_ep_values");
		$db->join('t_unit as unit1','unit1.id = t_user_ep_values.ep_q_unit');
        $db->where('user_id',$userid);
        $db->where('flow_name',$flowname);
        $query = $db->get();
        return $$query->getResultArray();
	}

}