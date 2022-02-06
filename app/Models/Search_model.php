<?php
namespace App\Models;

use CodeIgniter\Model;

class Search_model extends Model {

	public function __construct()
	{
		$this->load->database();
	}

	public function search_company($term){
		$this->db->select('*');
		$this->db->from('t_cmpny');
		$this->db->like('name', $term); 
		$this->db->or_like('description', $term);
		$query = $this->db->get();
		return $query->result_array();
	}

	public function search_project($term){
		$this->db->select('*');
		$this->db->from('t_prj');
		$this->db->like('name', $term); 
		$this->db->or_like('description', $term);
		$query = $this->db->get();
		return $query->result_array();
	}

}
?>