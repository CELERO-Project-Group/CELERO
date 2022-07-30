<?php
namespace App\Models;

use CodeIgniter\Model;

class Cluster_model extends Model {

	public function get_clusters(){
		$db = db_connect();
		$builder = $db->table('t_clstr');
		$builder->select('*');
		$builder->orderBy("name", "asc");
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function get_cluster_name($cluster_id){
		$db = db_connect();
        $builder = $db->table('t_clstr');
        $builder->select('name');
		$builder->where('id',$cluster_id);
        $query = $builder->get();
        return $query->getRowArray();
	}

	public function set_cmpny_clstr($data){
		$db = db_connect();
        $builder = $db->table('t_cmpny_clstr');
        $builder->insert($data);
	}

	public function can_write_info($cluster_id,$company_id){
		$db = db_connect();
        $builder = $db->table('t_cmpny_clstr');
        $builder->select('clstr_id');
		$builder->where('cmpny_id',$company_id);
        $query = $builder->get()->getRowArray();

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
