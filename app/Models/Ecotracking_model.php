<?php
namespace App\Models;

use CodeIgniter\Model;

class Ecotracking_model extends Model {

  public function __construct()
  {
    $db = db_connect();
  }

  public function save($company_id,$machine_id,$powera,$powerb,$powerc){
   $data = array(
      'company_id' => $company_id,
      'machine_id' => $machine_id,
      'powera' => $powera,
      'powerb' => $powerb,
      'powerc' => $powerc,
      'date' => date("Y-m-d H:i:s.ue")
    );
  	$db->insert('t_ecotracking',$data);
  }

  public function get($company_id,$machine_id){
  	$db->select('*');
  	$db->from('t_ecotracking');
  	$db->where('company_id',$company_id);
  	$db->where('machine_id',$machine_id);
    $db->order_by("date", "asc"); 
  	$data = $db->get()->result_array();
        //print_r($db->last_query());
        //print_r($data);
        return $data;
  }

}
?>
