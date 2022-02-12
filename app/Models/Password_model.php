<?php
namespace App\Models;

use CodeIgniter\Model;

class Password_model extends Model {

  public function __construct()
  {
    $db = db_connect();
  }

  public function do_similar_pass($user_id,$pass){
  	$db->select('psswrd');
  	$db->from('t_user');
  	$db->where('id',$user_id);
  	$query = $db->get()->row_array();
    if($query['psswrd'] == $pass)
    	return true;
    else
    	return false;
  }

  public function change_pass($user_id,$data){
    $db->where('id', $user_id);
    $db->update('t_user', $data);
  }

  public function get_email($user_id){
  	$db->select('email');
  	$db->from('t_user');
  	$db->where('id',$user_id);
  	$query = $db->get()->row_array();
    return $query; 
	}

  public function set_random_string($user_id,$rnd_str){
    $db->where('id', $user_id);
    $db->update('t_user', $rnd_str);
  }

  public function set_random_string_zero($random,$rnd_str){
    $db->where('random_string', $random);
    $db->update('t_user', $rnd_str);
  }

  public function click_control($rnd_str){
    $db->select('click_control');
    $db->from('t_user');
    $db->where('random_string',$rnd_str);
    $query = $db->get()->row_array();
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
    $db->select('id');
    $db->from('t_user');
    $db->where('random_string',$random);
    $query = $db->get()->row_array();
    return $query['id'];
  }

  public function get_id($email){
    $db->select('id');
    $db->from('t_user');
    $db->where('email',$email);
    $query = $db->get()->row_array();
    return $query['id'];
  }
}
?>
