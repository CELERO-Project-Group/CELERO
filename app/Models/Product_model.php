<?php
namespace App\Models;

use CodeIgniter\Model;

class Product_model extends Model {

	public function __construct()
	{
		$this->load->database();
	}

	public function register_product_to_company($product){
		$this->db->insert('t_prdct', $product);
	}

	public function get_product_list($id){
		$this->db->select("*");
		$this->db->from("t_prdct");
		$this->db->where("t_prdct.cmpny_id",$id);
		$query = $this->db->get();
		return $query->result_array();
	}

	public function get_product_by_cid_pid($companyID,$product_id){
		$this->db->select("*");
		$this->db->from("t_prdct");
		$this->db->where("t_prdct.cmpny_id",$companyID);
		$this->db->where("t_prdct.id",$product_id);
		$query = $this->db->get();
		return $query->row_array();
	}

	public function set_product($data){
		$this->db->insert('t_prdct',$data);
	}

	public function delete_product($id){
		$this->db->where('id', $id);
		$this->db->delete('t_prdct'); 
	}

	public function update_product($companyID,$product_id,$productArray){
    $this->db->where('t_prdct.cmpny_id',$companyID);   
    $this->db->where('t_prdct.id',$product_id);   
    $this->db->update('t_prdct',$productArray); 
	}
}