<?php
namespace App\Models;

use CodeIgniter\Model;

class Ecotracking_model extends Model {

  public function __construct()
  {
    $this->load->database();
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
  	$this->db->insert('t_ecotracking',$data);
  }

  public function get($company_id,$machine_id){
  	$this->db->select('*');
  	$this->db->from('t_ecotracking');
  	$this->db->where('company_id',$company_id);
  	$this->db->where('machine_id',$machine_id);
    $this->db->order_by("date", "asc"); 
  	$data = $this->db->get()->result_array();
        //print_r($this->db->last_query());
        //print_r($data);
        return $data;
  }

}
?>
