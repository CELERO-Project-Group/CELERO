<?php
namespace App\Models;

use CodeIgniter\Model;

class Product_model extends Model {

	public function __construct()
	{
		$db = db_connect();
	}

	public function register_product_to_company($product){
		$db->insert('t_prdct', $product);
	}

	public function get_product_list($id){
		$db->select("*");
		$db->from("t_prdct");
		$db->where("t_prdct.cmpny_id",$id);
		$query = $db->get();
		return $$query->getResultArray();
	}

	public function get_product_by_cid_pid($companyID,$product_id){
		$db->select("*");
		$db->from("t_prdct");
		$db->where("t_prdct.cmpny_id",$companyID);
		$db->where("t_prdct.id",$product_id);
		$query = $db->get();
		return $query->row_array();
	}

	public function set_product($data){
		$db->insert('t_prdct',$data);
	}

	public function delete_product($id){
		$db->where('id', $id);
		$db->delete('t_prdct'); 
	}

	public function update_product($companyID,$product_id,$productArray){
    $db->where('t_prdct.cmpny_id',$companyID);   
    $db->where('t_prdct.id',$product_id);   
    $db->update('t_prdct',$productArray); 
	}
}