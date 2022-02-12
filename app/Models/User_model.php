<?php
namespace App\Models;

use CodeIgniter\Model;

class User_model extends Model {

  public function __construct()
  {
    $db = db_connect();
  }

  public function create_user($data){
    $db->insert('t_user', $data);
    return $db->insert_id();
  }

  public function get_userinfo_by_username($username){
    $db->select('*');
    $db->from('t_user');
    $db->where('user_name',$username);
    return $db->get()->row_array();
  }

  public function check_user($username,$password){
  	$db->from('t_user');
  	$db->where('user_name',$username);
  	$db->where('psswrd',$password);
        
  	$query = $db->get();
        //print_r($db->last_query());
        //$db->get_compiled_select();
  	if($query -> num_rows() == 1)
  	{
  		return $query->row_array();
  	}
  	else
  	{
  		return false;
  	}
  }

  /**
   * [get_consultants description]
   * @return all consultant information in the system ordered by name
   */
  public function get_consultants(){
    $db->select('t_user.id as id,t_user.user_name as user_name,t_user.name as name,t_user.surname as surname,t_user.description as description');
    $db->from('t_user');
    $db->join('t_role', 't_role.id = t_user.role_id');
    $db->where('t_role.short_code', 'CNS');
    $db->order_by("name", "asc");
    $query = $db->get();
    return $$query->getResultArray();

  }

  public function get_company_users($cmpny_id){
    $db->select('t_user.name as name,t_user.surname as surname,t_user.id as id,t_cmpny.name as cmpny_name');
    $db->from('t_cmpny_prsnl');
    $db->join('t_cmpny', 't_cmpny.id = t_cmpny_prsnl.cmpny_id');
    $db->join('t_user', 't_user.id = t_cmpny_prsnl.user_id');
    $db->where('t_cmpny_prsnl.cmpny_id', $cmpny_id);
    $query = $db->get();
    if($query->num_rows() > 0)
    {
      return $$query->getResultArray();
    }
    else
    {
      return false;
    }
  }

  // Session dan acik olan kisinin username bilgisi aliniyor ve bu username e sahip
  // kisinin butun bilgileri controller a return ediliyor.
  public function get_session_user(){
    if (isset($_SESSION['user_in'])){
      $tmp = $this->session->userdata('user_in');

      $db->from('t_user');
      $db->where('id',$tmp['id']);
      $query = $db->get();

      if($query -> num_rows() == 1)
      {
        return $query->row_array();
      }
      else
      {
        return false;
      }
    }
  }

  public function get_user($id){
    $db->select('*');
    $db->from('t_user');
    $db->where('id', $id);
    $query = $db->get();
    return $$query->getResultArray();
  }

  public function get_all_users(){
    $db->select('*');
    $db->from('t_user');
    $db->order_by("name", "asc");
    $query = $db->get();
    return $$query->getResultArray();
  }

  public function get_worker_projects_from_userid($id){
      $db->select('t_prj.name,t_prj.id as proje_id');
      $db->from('t_prj');
      $db->join('t_prj_cntct_prsnl', 't_prj_cntct_prsnl.prj_id = t_prj.id');
      $db->join('t_user', 't_user.id = t_prj_cntct_prsnl.usr_id');
      $db->where('t_user.id', $id);
      $query = $db->get();
      return $$query->getResultArray();
  }

  public function deneme_json($id){
      $db->select('t_prj.name as text,t_prj.id as id');
      $db->from('t_prj');
      $db->join('t_prj_cnsltnt', 't_prj_cnsltnt.prj_id = t_prj.id');
      $db->join('t_user', 't_user.id = t_prj_cnsltnt.cnsltnt_id');
      $db->where('t_user.id', $id);
      $query = $db->get();
      return $$query->getResultArray();
  }

  public function get_consultant_projects_from_userid($id){
      $db->select('t_prj.name,t_prj.id as proje_id');
      $db->from('t_prj');
      $db->join('t_prj_cnsltnt', 't_prj_cnsltnt.prj_id = t_prj.id');
      $db->join('t_user', 't_user.id = t_prj_cnsltnt.cnsltnt_id');
      $db->where('t_user.id', $id);
      $db->order_by("t_prj.name", "asc");
      $query = $db->get();
      return $$query->getResultArray();
  }

  public function update_user($update){
    if (isset($_SESSION['user_in'])){
      $tmp = $this->session->userdata('user_in');
      $db->where('id', $tmp['id']);
      $db->update('t_user', $update);
    }
  }

  public function make_user_consultant($id,$username=FALSE){
    if(empty($username)){
      $username = "Username";
    }

    // T_cnsltnt'a ekleme
    $data = array(
      'user_id' => $id,
      'description' => $username,
      'active' => '1'
    );
    $db->insert('t_cnsltnt', $data);

    //T_USER'ı güncelleme
    $data = array(
      'role_id' => '1'
    );
    $db->where('id', $id);
    $db->update('t_user', $data);
  }

  public function is_user_consultant($id){
    //kullanıcı consultant ise true değilse false döndürür
    $db->select('*');
    $db->from('t_user');
    $db->where('id', $id);
    $query = $db->get()->row_array();
    if($query['role_id']=="1"){
      return TRUE;
    }
    else{
      return FALSE;
    }
  }

  public function check_user_email($email){
    $db->from('t_user');
    $db->where('email',$email);
    $query = $db->get();

    if($query -> num_rows() == 1)
      return true;
    else
      return false;
  }

  public function check_username($username){
    $db->from('t_user');
    $db->where('user_name',$username);
    $query = $db->get();

    if($query -> num_rows() == 1)
      return true;
    else
      return false;
  }

  public function set_user_image($userId,$photo){
    $db->where('id', $userId);
    $db->update('t_user', $photo);
  }

  public function users_without_company(){
    $db->select('*')->from('t_user');
    $db->where('`id` NOT IN (SELECT `user_id` FROM `t_cmpny_prsnl`)', NULL, FALSE);
    $query = $db->get();
    return $$query->getResultArray();
  }

  public function do_consultant($id){
    $db->select('t_role.short_code');
    $db->from('t_role');
    $db->join('t_user','t_user.role_id = t_role.id');
    $db->where('t_user.id',$id);
    $query = $db->get();
    return $query->row_array();
  }

  //Bir danışmanın danışman olduğu şirketleri listeler
  public function do_edit_company_consultant($user_id){
    $db->select('t_prj_cmpny.cmpny_id as cmpnyID');
    $db->from('t_prj_cnsltnt');
    $db->join('t_prj_cmpny', 't_prj_cmpny.prj_id = t_prj_cnsltnt.prj_id');
    $db->where('t_prj_cnsltnt.cnsltnt_id',$user_id);
    $query = $db->get()->result_array();
    return $query;
  }

  //Bir kullanıcı bir şirketin danışmanı mıdır?
  public function is_consultant_of_company_by_user_id($user_id,$company_id){
    $db->select('t_prj_cmpny.cmpny_id as cmpnyID');
    $db->from('t_prj_cnsltnt');
    $db->join('t_prj_cmpny', 't_prj_cmpny.prj_id = t_prj_cnsltnt.prj_id');
    $db->where('t_prj_cnsltnt.cnsltnt_id',$user_id);
    $db->where('t_prj_cmpny.cmpny_id',$company_id);
    $query = $db->get()->result_array();
    if(empty($query)){
      return FALSE;
    }else{
      return TRUE;
    }
  }

  public function is_consultant_of_project_by_user_id($user_id,$prj_id){
    $db->select('*');
    $db->from('t_prj_cnsltnt');
    $db->where('t_prj_cnsltnt.cnsltnt_id',$user_id);
    $db->where('t_prj_cnsltnt.prj_id',$prj_id);
    $query = $db->get()->result_array();
    if(empty($query)){
      return FALSE;
    }else{
      return TRUE;
    }
  }

  public function is_contactperson_of_project_by_user_id($user_id,$prj_id){
    $db->select('*');
    $db->from('t_prj_cntct_prsnl');
    $db->where('t_prj_cntct_prsnl.usr_id',$user_id);
    $db->where('t_prj_cntct_prsnl.prj_id',$prj_id);
    $query = $db->get()->result_array();
    if(empty($query)){
      return FALSE;
    }else{
      return TRUE;
    }
  }

  public function cmpny_prsnl($user_id){
    $db->select('cmpny_id');
    $db->from('t_cmpny_prsnl');
    $db->where('user_id',$user_id);
    $query = $db->get();
    return $query->row_array();
  }

  //Firmanın contact person'ı mı?
  public function is_contact_by_userid($user_id,$company_id){
    $db->select('*');
    $db->from('t_cmpny_prsnl');
    $db->where('user_id',$user_id);
    $db->where('cmpny_id', $company_id);
    $db->where('is_contact', '1');
    $query = $db->get()->row_array();
    if(empty($query))
      return FALSE;
    else
      return TRUE;
  }

  //verilen user'ın verilen şirketi edit edip edemeyeceğine dair bilgiyi verir
  public function can_edit_company($user_id,$company_id){
    $consultant = $this->is_consultant_of_company_by_user_id($user_id,$company_id);
    $contact = $this->is_contact_by_userid($user_id,$company_id);
    return $consultant || $contact;
  }

  public function create_dataset_for_users($data){
    $db->insert('t_users_data', $data);
    return $db->insert_id();
  }

}
?>
