<?php
namespace App\Models;

use CodeIgniter\Model;

class Equipment_model extends Model {

  public function __construct()
  {
    $this->load->database();
  }

  public function get_equipment_name(){
    $this->db->select('*');
    $this->db->from('t_eqpmnt');
    $query = $this->db->get();
    return $query->result_array();
  }

  public function cmpny_prcss($id){
    $this->db->select('t_prcss.name as prcessname,t_prcss.id as processid');
    $this->db->from('t_cmpny_prcss');
    $this->db->join('t_prcss','t_cmpny_prcss.prcss_id = t_prcss.id');
    $this->db->where('t_cmpny_prcss.cmpny_id',$id);
    $query = $this->db->get();
    return $query->result_array();
  }

  public function get_cmpny_process($id){
    $this->db->select('t_cmpny_prcss.id');
    $this->db->from('t_cmpny_prcss');
    $this->db->where('t_cmpny_prcss.prcss_id',$id);
    $query = $this->db->get();
    return $query->row_array();
  }

  public function get_equipment_type_list($equipment_id){
    $this->db->select('id,name');
    $this->db->from('t_eqpmnt_type');
    $this->db->where('mother_id',$equipment_id);
    $query = $this->db->get()->result_array();
    return $query;
  }

  public function get_equipment_attribute_list($equipment_type_id){
    $this->db->select('id,attribute_name');
    $this->db->from('t_eqpmnt_type_attrbt');
    $this->db->where('eqpmnt_type_id',$equipment_type_id);
    $query = $this->db->get()->result_array();
    return $query;
  }

  public function set_info($data){  
    $this->db->insert('t_cmpny_eqpmnt',$data);
    return $this->db->insert_id();
  }

  public function all_information_of_equipment($companyID){
    $this->db->select('t_cmpny.name as fathername, t_cmpny_eqpmnt.cmpny_id as companyfatherid, t_cmpny_eqpmnt.eqpmnt_attrbt_val,t_cmpny_eqpmnt.id as cmpny_eqpmnt_id, t_eqpmnt.name as eqpmnt_name, t_eqpmnt_type.name as eqpmnt_type_name, t_eqpmnt_type_attrbt.attribute_name as eqpmnt_type_attrbt_name, t_prcss.name as prcss_name,unit1.name as unit');
    $this->db->from('t_cmpny_prcss_eqpmnt_type');
    $this->db->join('t_cmpny_eqpmnt','t_cmpny_eqpmnt.id = t_cmpny_prcss_eqpmnt_type.cmpny_eqpmnt_type_id','left');
    $this->db->join('t_eqpmnt','t_eqpmnt.id = t_cmpny_eqpmnt.eqpmnt_id','left');
    $this->db->join('t_eqpmnt_type','t_eqpmnt_type.id = t_cmpny_eqpmnt.eqpmnt_type_id','left');
    $this->db->join('t_eqpmnt_type_attrbt','t_eqpmnt_type_attrbt.id = t_cmpny_eqpmnt.eqpmnt_type_attrbt_id','left');
    $this->db->join('t_cmpny_prcss','t_cmpny_prcss.id = t_cmpny_prcss_eqpmnt_type.cmpny_prcss_id','left');
    $this->db->join('t_prcss','t_prcss.id = t_cmpny_prcss.prcss_id','left');
    $this->db->join('t_unit as unit1','unit1.id = t_cmpny_eqpmnt.eqpmnt_attrbt_unit','left');
    $this->db->join('t_cmpny', 't_cmpny.id = t_cmpny_eqpmnt.cmpny_id','left');
    $this->db->where('t_cmpny_eqpmnt.cmpny_id',$companyID);
    $query = $this->db->get()->result_array();
    return $query;
  }

  public function get_cmpny_prcss_id($companyID,$prcss_id){
    $this->db->select('id');
    $this->db->from('t_cmpny_prcss');
    $this->db->where('cmpny_id',$companyID);
    $this->db->where('prcss_id',$prcss_id);
    $query = $this->db->get()->row_array();
    return $query;
  }

  public function set_cmpny_prcss($data){
    $this->db->insert('t_cmpny_prcss_eqpmnt_type',$data);
  }

  public function delete_cmpny_equipment($cmpny_prcss_id){
    $this->db->where('cmpny_prcss_id', $cmpny_prcss_id);
    $this->db->delete('t_cmpny_prcss_eqpmnt_type'); 
  
  }

  public function delete_cmpny_prcss_eqpmnt_type($cmpny_eqpmnt_id){
    $this->db->where('cmpny_eqpmnt_type_id', $cmpny_eqpmnt_id);
    $this->db->delete('t_cmpny_prcss_eqpmnt_type'); 
  }

  public function delete_cmpny_eqpmnt($id){
    $this->db->where('id', $id);
    $this->db->delete('t_cmpny_eqpmnt'); 
  }
}
?>
