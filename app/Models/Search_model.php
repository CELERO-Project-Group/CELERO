<?php
namespace App\Models;

use CodeIgniter\Model;

class Search_model extends Model {

	public function __construct()
	{
		$db = db_connect();
	}

	public function search_company($term){
		$db->select('*');
		$db->from('t_cmpny');
		$db->like('name', $term); 
		$db->or_like('description', $term);
		$query = $db->get();
		return $$query->getResultArray();
	}

	public function search_project($term){
		$db->select('*');
		$db->from('t_prj');
		$db->like('name', $term); 
		$db->or_like('description', $term);
		$query = $db->get();
		return $$query->getResultArray();
	}

}
?>