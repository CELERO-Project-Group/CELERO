<?php
namespace App\Models;

use CodeIgniter\Model;

class Cluster_model extends Model {

  public function __construct()
  {
    $db = db_connect();
  }

  public function get_clusters(){
    $db->select('*');
    $db->from('t_clstr');
    $query = $db->get()->result_array();
    return $query;
  }

  public function get_cluster_name($cluster_id){
    $db->select('name');
    $db->from('t_clstr');
    $db->where('id',$cluster_id);
    $query = $db->get()->row_array();
    return $query;
  }

  public function set_cmpny_clstr($data){
    $db->insert('t_cmpny_clstr',$data);
  }

  public function can_write_info($cluster_id,$company_id){
    $db->select('clstr_id');
    $db->from('t_cmpny_clstr');
    $db->where('cmpny_id',$company_id);
    $query = $db->get()->result_array();
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
