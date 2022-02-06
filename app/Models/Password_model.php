<?php
namespace App\Models;

use CodeIgniter\Model;

class Password_model extends Model {

  public function __construct()
  {
    $this->load->database();
  }

  public function do_similar_pass($user_id,$pass){
  	$this->db->select('psswrd');
  	$this->db->from('t_user');
  	$this->db->where('id',$user_id);
  	$query = $this->db->get()->row_array();
    if($query['psswrd'] == $pass)
    	return true;
    else
    	return false;
  }

  public function change_pass($user_id,$data){
    $this->db->where('id', $user_id);
    $this->db->update('t_user', $data);
  }

  public function get_email($user_id){
  	$this->db->select('email');
  	$this->db->from('t_user');
  	$this->db->where('id',$user_id);
  	$query = $this->db->get()->row_array();
    return $query; 
	}

  public function set_random_string($user_id,$rnd_str){
    $this->db->where('id', $user_id);
    $this->db->update('t_user', $rnd_str);
  }

  public function set_random_string_zero($random,$rnd_str){
    $this->db->where('random_string', $random);
    $this->db->update('t_user', $rnd_str);
  }

  public function click_control($rnd_str){
    $this->db->select('click_control');
    $this->db->from('t_user');
    $this->db->where('random_string',$rnd_str);
    $query = $this->db->get()->row_array();
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
    $this->db->select('id');
    $this->db->from('t_user');
    $this->db->where('random_string',$random);
    $query = $this->db->get()->row_array();
    return $query['id'];
  }

  public function get_id($email){
    $this->db->select('id');
    $this->db->from('t_user');
    $this->db->where('email',$email);
    $query = $this->db->get()->row_array();
    return $query['id'];
  }
}
?>
