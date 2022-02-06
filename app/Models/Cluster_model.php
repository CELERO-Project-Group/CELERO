<?php
namespace App\Models;

use CodeIgniter\Model;

class Cluster_model extends Model {

  public function __construct()
  {
    $this->load->database();
  }

  public function get_clusters(){
    $this->db->select('*');
    $this->db->from('t_clstr');
    $query = $this->db->get()->result_array();
    return $query;
  }

  public function get_cluster_name($cluster_id){
    $this->db->select('name');
    $this->db->from('t_clstr');
    $this->db->where('id',$cluster_id);
    $query = $this->db->get()->row_array();
    return $query;
  }

  public function set_cmpny_clstr($data){
    $this->db->insert('t_cmpny_clstr',$data);
  }

  public function can_write_info($cluster_id,$company_id){
    $this->db->select('clstr_id');
    $this->db->from('t_cmpny_clstr');
    $this->db->where('cmpny_id',$company_id);
    $query = $this->db->get()->result_array();
    if(empty($query)){
      return true;
    }else{
      foreach ($query as $var) {
        if($var['clstr_id'] == $cluster_id){
          return false;
        }
      }
      return true;
    }
  }
}
?>
