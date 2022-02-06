<?php 
namespace App\Models;

use CodeIgniter\Model;

class Component_model extends Model {

	public function __construct()
	{
		$this->load->database();
	}

	public function get_cmpny_flow_and_flow_type($cmpny_id){
		$this->db->select('t_cmpny_flow.id as value_id, t_flow.name as flow_name, t_flow_type.name as flow_type_name');
		$this->db->from('t_cmpny_flow');
		$this->db->join('t_flow','t_flow.id = t_cmpny_flow.flow_id');
		$this->db->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id');
		$this->db->where('t_cmpny_flow.cmpny_id',$cmpny_id);
		$query = $this->db->get()->result_array();
    	return $query;
	}

	public function set_cmpnnt($data){
		$this->db->insert('t_cmpnnt',$data);
		return $this->db->insert_id();
	}

	public function update_cmpnnt($data,$id,$company_id){
    $this->db->where('t_cmpnnt.id',$id);   
    $this->db->where('t_cmpnnt.cmpny_id',$company_id);   
    $this->db->update('t_cmpnnt',$data); 
	}

	//gets component types
	public function get_cmpnnt_type(){
		$this->db->select('*');
		$this->db->from('t_cmpnt_type');
		return $this->db->get()->result_array();
	}

	public function set_cmpny_flow_cmpnnt($data){
		$this->db->insert('t_cmpny_flow_cmpnnt',$data);
	}

	public function update_cmpny_flow_cmpnnt($data,$id){
    $this->db->where('t_cmpny_flow_cmpnnt.cmpnnt_id',$id);   
    $this->db->update('t_cmpny_flow_cmpnnt',$data); 	
  }

	public function get_cmpnnt($cmpny_id){
		$this->db->select('*,t_cmpnt_type.name as type_name,t_unit.name as qntty_name, t_cmpnnt.id as id,t_cmpnnt.name as component_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name');
		$this->db->from('t_cmpny_flow');
		$this->db->join('t_cmpny_flow_cmpnnt','t_cmpny_flow.id = t_cmpny_flow_cmpnnt.cmpny_flow_id');
		$this->db->join('t_cmpnnt','t_cmpny_flow_cmpnnt.cmpnnt_id = t_cmpnnt.id');
		$this->db->join('t_cmpnt_type','t_cmpny_flow_cmpnnt.cmpnt_type_id = t_cmpnt_type.id','left');
		$this->db->join('t_unit','t_unit.id = t_cmpny_flow_cmpnnt.qntty_unit_id','left');
		$this->db->join('t_flow','t_flow.id = t_cmpny_flow.flow_id ');
		$this->db->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id ');
		$this->db->where('t_cmpny_flow.cmpny_id',$cmpny_id);
		$query = $this->db->get()->result_array();
    	return $query;
	}

	public function get_cmpnnt_info($cmpny_id,$id){
		$this->db->select('*, t_cmpnnt.id as id,t_cmpnnt.name as component_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name');
		$this->db->from('t_cmpny_flow');
		$this->db->join('t_cmpny_flow_cmpnnt','t_cmpny_flow.id = t_cmpny_flow_cmpnnt.cmpny_flow_id');
		$this->db->join('t_cmpnnt','t_cmpny_flow_cmpnnt.cmpnnt_id = t_cmpnnt.id');
		$this->db->join('t_cmpnt_type','t_cmpny_flow_cmpnnt.cmpnt_type_id = t_cmpnt_type.id','left');
		$this->db->join('t_flow','t_flow.id = t_cmpny_flow.flow_id ');
		$this->db->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id ');
		$this->db->where('t_cmpny_flow.cmpny_id',$cmpny_id);
		$this->db->where('t_cmpnnt.id',$id);
		$query = $this->db->get()->row_array();
    	return $query;
	}

	public function delete_flow_cmpnnt_by_flowID($id){
		$this->db->where('cmpny_flow_id', $id);
		$this->db->delete('t_cmpny_flow_cmpnnt'); 
	}

	public function delete_flow_cmpnnt_by_cmpnntID($id){
		$this->db->where('cmpnnt_id', $id);
		$this->db->delete('t_cmpny_flow_cmpnnt'); 
	}

	public function delete_cmpnnt($cmpny_id,$id){
		$this->db->where('cmpny_id',$cmpny_id);
		$this->db->where('id', $id);
		$this->db->delete('t_cmpnnt'); 
	}
}