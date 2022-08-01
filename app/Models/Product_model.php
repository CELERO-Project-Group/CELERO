<?php

namespace App\Models;

use CodeIgniter\Model;

class Product_model extends Model
{

	public function register_product_to_company($product)
	{
		$db = db_connect();
		$builder = $db->table('t_prdct');
		$builder->insert($product);
	}

	public function get_product_list($id)
	{
		$db = db_connect();
		$builder = $db->table('t_prdct');
		$builder->select("*");
		$builder->where("t_prdct.cmpny_id", $id);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function get_product_by_cid_pid($companyID, $product_id)
	{
		$db = db_connect();
		$builder = $db->table('t_prdct');
		$builder->select('*');
		$builder->where("t_prdct.cmpny_id", $companyID);
		$builder->where("t_prdct.id", $product_id);
		$query = $builder->get();
		return $query->getRowArray();
	}

	public function set_product($data)
	{
		$db = db_connect();
		$builder = $db->table('t_prdct');
		$builder->insert($data);
	}

	public function delete_product($id)
	{
		$db = db_connect();
        $builder = $db->table('t_prdct');
        $builder->delete(['id' => $id]);
	}

	public function update_product($companyID, $product_id, $productArray)
	{
		$db = db_connect();
		$builder = $db->table('t_prdct');
		$builder->where('t_prdct.cmpny_id', $companyID);
		$builder->where('t_prdct.id', $product_id);
		$builder->update($productArray);
	}
}
