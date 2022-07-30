<?php
namespace App\Models;

use CodeIgniter\Model;

class Password_model extends Model {

	public function do_similar_pass($user_id,$pass){
		$db = db_connect();
        $builder = $db->table('t_user');
        $builder->select('psswrd');
		$builder->where('id',$user_id);
        $query = $builder->get()->getRowArray();
		if($query['psswrd'] == $pass)
			return true;
		else
			return false;
	}

	public function change_pass($user_id,$data){
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->where('id', $user_id);
		$builder->replace($data);
	}

	public function get_email($user_id){
		$db = db_connect();
        $builder = $db->table('t_user');
        $builder->select('email');
		$builder->where('id',$user_id);
        $query = $builder->get()->getRowArray();
		return $query; 
	}

	public function set_random_string($user_id,$rnd_str){
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->where('id', $user_id);
		$builder->replace($rnd_str);
	}

	public function set_random_string_zero($random,$rnd_str){
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->where('random_string', $random);
		$builder->replace($rnd_str);
	}

	public function click_control($rnd_str){
		$db = db_connect();
        $builder = $db->table('t_user');
        $builder->select('click_control');
		$builder->where('random_string',$rnd_str);
        $query = $builder->get()->getRowArray();
		if(!empty($query)){
			if($query['click_control'] == 1)  
				return true;
			else
				return false;
		}
		else{
			return false;
		}
	}

	public function get_user_id($random){
		$db = db_connect();
        $builder = $db->table('t_user');
        $builder->select('id');
		$builder->where('random_string',$random);
        $query = $builder->get()->getRowArray();
		return $query['id'];
	}

	public function get_id($email){
		$db = db_connect();
        $builder = $db->table('t_user');
        $builder->select('id');
		$builder->where('email',$email);
        $query = $builder->get()->getRowArray();
		return $query['id'];
	}
}
?>
