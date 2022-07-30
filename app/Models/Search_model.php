<?php
namespace App\Models;

use CodeIgniter\Model;

class Search_model extends Model {

	public function search_company($term){
		$db = db_connect();
		$builder = $db->table('t_cmpny');
		$builder->select('*');
		$builder->like('name', $term); 
		$builder->orLike('description', $term);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function search_project($term){
		$db = db_connect();
		$builder = $db->table('t_prj');
		$builder->select('*');
		$builder->like('name', $term); 
		$builder->orLike('description', $term);
		$query = $builder->get();
		return $query->getResultArray();
	}

}
?>