<?php 
namespace App\Models;

use CodeIgniter\Model;

class Component_model extends Model {

	public function __construct()
	{
		$db = db_connect();
	}

	public function get_cmpny_flow_and_flow_type($cmpny_id){
		$db->select('t_cmpny_flow.id as value_id, t_flow.name as flow_name, t_flow_type.name as flow_type_name');
		$db->from('t_cmpny_flow');
		$db->join('t_flow','t_flow.id = t_cmpny_flow.flow_id');
		$db->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id');
		$db->where('t_cmpny_flow.cmpny_id',$cmpny_id);
		$query = $db->get()->result_array();
    	return $query;
	}

	public function set_cmpnnt($data){
		$db->insert('t_cmpnnt',$data);
		return $db->insert_id();
	}

	public function update_cmpnnt($data,$id,$company_id){
    $db->where('t_cmpnnt.id',$id);   
    $db->where('t_cmpnnt.cmpny_id',$company_id);   
    $db->update('t_cmpnnt',$data); 
	}

	//gets component types
	public function get_cmpnnt_type(){
		$db->select('*');
		$db->from('t_cmpnt_type');
		return $db->get()->result_array();
	}

	public function set_cmpny_flow_cmpnnt($data){
		$db->insert('t_cmpny_flow_cmpnnt',$data);
	}

	public function update_cmpny_flow_cmpnnt($data,$id){
    $db->where('t_cmpny_flow_cmpnnt.cmpnnt_id',$id);   
    $db->update('t_cmpny_flow_cmpnnt',$data); 	
  }

	public function get_cmpnnt($cmpny_id){
		$db->select('*,t_cmpnt_type.name as type_name,t_unit.name as qntty_name, t_cmpnnt.id as id,t_cmpnnt.name as component_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name');
		$db->from('t_cmpny_flow');
		$db->join('t_cmpny_flow_cmpnnt','t_cmpny_flow.id = t_cmpny_flow_cmpnnt.cmpny_flow_id');
		$db->join('t_cmpnnt','t_cmpny_flow_cmpnnt.cmpnnt_id = t_cmpnnt.id');
		$db->join('t_cmpnt_type','t_cmpny_flow_cmpnnt.cmpnt_type_id = t_cmpnt_type.id','left');
		$db->join('t_unit','t_unit.id = t_cmpny_flow_cmpnnt.qntty_unit_id','left');
		$db->join('t_flow','t_flow.id = t_cmpny_flow.flow_id ');
		$db->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id ');
		$db->where('t_cmpny_flow.cmpny_id',$cmpny_id);
		$query = $db->get()->result_array();
    	return $query;
	}

	public function get_cmpnnt_info($cmpny_id,$id){
		$db->select('*, t_cmpnnt.id as id,t_cmpnnt.name as component_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name');
		$db->from('t_cmpny_flow');
		$db->join('t_cmpny_flow_cmpnnt','t_cmpny_flow.id = t_cmpny_flow_cmpnnt.cmpny_flow_id');
		$db->join('t_cmpnnt','t_cmpny_flow_cmpnnt.cmpnnt_id = t_cmpnnt.id');
		$db->join('t_cmpnt_type','t_cmpny_flow_cmpnnt.cmpnt_type_id = t_cmpnt_type.id','left');
		$db->join('t_flow','t_flow.id = t_cmpny_flow.flow_id ');
		$db->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id ');
		$db->where('t_cmpny_flow.cmpny_id',$cmpny_id);
		$db->where('t_cmpnnt.id',$id);
		$query = $db->get()->row_array();
    	return $query;
	}

	public function delete_flow_cmpnnt_by_flowID($id){
		$db->where('cmpny_flow_id', $id);
		$db->delete('t_cmpny_flow_cmpnnt'); 
	}

	public function delete_flow_cmpnnt_by_cmpnntID($id){
		$db->where('cmpnnt_id', $id);
		$db->delete('t_cmpny_flow_cmpnnt'); 
	}

	public function delete_cmpnnt($cmpny_id,$id){
		$db->where('cmpny_id',$cmpny_id);
		$db->where('id', $id);
		$db->delete('t_cmpnnt'); 
	}
}