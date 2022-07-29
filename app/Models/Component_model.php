<?php 
namespace App\Models;

use CodeIgniter\Model;

class Component_model extends Model {

	public function __construct()
	{
		$db = db_connect();
	}

	public function get_cmpny_flow_and_flow_type($cmpny_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow');
		$builder->select('t_cmpny_flow.id as value_id, t_flow.name as flow_name, t_flow_type.name as flow_type_name');
		$builder->join('t_flow','t_flow.id = t_cmpny_flow.flow_id');
		$builder->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id');
		$builder->where('t_cmpny_flow.cmpny_id',$cmpny_id);
		$query = $builder->get();
        return $query->getResultArray();
	}

	public function set_cmpnnt($data){
		$db = db_connect();
        $builder = $db->table('t_cmpnnt');
        $builder->insert($data);
        return $db->insertID();
	}

	public function update_cmpnnt($data,$id,$company_id){
		$db = db_connect();
		$builder = $db->table('t_cmpnnt');
		$builder->where('t_cmpnnt.cmpny_id',$company_id); 
		$builder->where('t_cmpnnt.id',$id);     
		$builder->replace($data);
	}

	//gets component types
	public function get_cmpnnt_type(){
		$db = db_connect();
        $builder = $db->table('t_cmpnt_type');
		$builder->select('*');
		$query = $builder->get();
        return $query->getResultArray();
	}

	public function set_cmpny_flow_cmpnnt($data){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_cmpnnt');
        $builder->insert($data);
	}

	public function update_cmpny_flow_cmpnnt($data,$id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_cmpnnt');
        $builder->where('t_cmpny_flow_cmpnnt.cmpnnt_id',$id); 
        $builder->replace($data);
	}

	public function get_cmpnnt($cmpny_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow');
		$builder->select('*,t_cmpnt_type.name as type_name,t_unit.name as qntty_name, t_cmpnnt.id as id,t_cmpnnt.name as component_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name');
        $builder->join('t_cmpny_flow_cmpnnt','t_cmpny_flow.id = t_cmpny_flow_cmpnnt.cmpny_flow_id');
		$builder->join('t_cmpnnt','t_cmpny_flow_cmpnnt.cmpnnt_id = t_cmpnnt.id');
		$builder->join('t_cmpnt_type','t_cmpny_flow_cmpnnt.cmpnt_type_id = t_cmpnt_type.id','left');
		$builder->join('t_unit','t_unit.id = t_cmpny_flow_cmpnnt.qntty_unit_id','left');
		$builder->join('t_flow','t_flow.id = t_cmpny_flow.flow_id ');
		$builder->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id ');
		$builder->where('t_cmpny_flow.cmpny_id',$cmpny_id);
        $query = $builder->get();
        return $query->getResultArray();
	}

	public function get_cmpnnt_info($cmpny_id,$id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow');
		$builder->select('*, t_cmpnnt.id as id,t_cmpnnt.name as component_name, t_flow.name as flow_name, t_flow_type.name as flow_type_name');
		$builder->join('t_cmpny_flow_cmpnnt','t_cmpny_flow.id = t_cmpny_flow_cmpnnt.cmpny_flow_id');
		$builder->join('t_cmpnnt','t_cmpny_flow_cmpnnt.cmpnnt_id = t_cmpnnt.id');
		$builder->join('t_cmpnt_type','t_cmpny_flow_cmpnnt.cmpnt_type_id = t_cmpnt_type.id','left');
		$builder->join('t_flow','t_flow.id = t_cmpny_flow.flow_id ');
		$builder->join('t_flow_type','t_flow_type.id = t_cmpny_flow.flow_type_id ');
		$builder->where('t_cmpny_flow.cmpny_id',$cmpny_id);
		$builder->where('t_cmpnnt.id',$id);
		$query = $builder->get();
        return $query->getRowArray();
	}

	public function delete_flow_cmpnnt_by_flowID($id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_cmpnnt');
		$builder->where('cmpny_flow_id', $id);
        $builder->delete();
	}

	public function delete_flow_cmpnnt_by_cmpnntID($id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_flow_cmpnnt');
		$builder->where('cmpnnt_id', $id);
        $builder->delete();
	}

	public function delete_cmpnnt($cmpny_id,$id){
		$db = db_connect();
        $builder = $db->table('t_cmpnnt');
		$builder->where('cmpny_id',$cmpny_id);
		$builder->where('id', $id);
        $builder->delete();
	}
}