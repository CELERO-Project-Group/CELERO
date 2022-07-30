<?php

namespace App\Models;

use CodeIgniter\Model;

class User_model extends Model
{

	public function create_user($data)
	{
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->insert($data);
		return $db->insertID();
	}

	public function get_userinfo_by_username($username)
	{
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->select('*');
		$builder->where('user_name', $username);
		$query = $builder->get();
		return $query->getRowArray();
	}

	public function check_user($username, $password)
	{
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->where('user_name', $username);
		$builder->where('psswrd', $password);
		$query = $builder->get();

		if ($query->getFieldCount() > 1) {
			return $query->getRowArray();
		} else {
			return false;
		}
	}

	/**
	 * [get_consultants description]
	 * @return all consultant information in the system ordered by name
	 */
	public function get_consultants()
	{
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->select('t_user.id as id,t_user.user_name as user_name,t_user.name as name,t_user.surname as surname,t_user.description as description');
		$builder->join('t_role', 't_role.id = t_user.role_id');
		$builder->where('t_role.short_code', 'CNS');
		$builder->orderBy("name", "asc");
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function get_company_users($cmpny_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cmpny_prsnl');
		$builder->select('t_user.name as name,t_user.surname as surname,t_user.id as id,t_cmpny.name as cmpny_name');
		$builder->join('t_cmpny', 't_cmpny.id = t_cmpny_prsnl.cmpny_id');
		$builder->join('t_user', 't_user.id = t_cmpny_prsnl.user_id');
		$builder->where('t_cmpny_prsnl.cmpny_id', $cmpny_id);
		$query = $builder->get();
		if ($query->getFieldCount() > 0) {
			return $query->getResultArray();
		} else {
			return false;
		}
	}

	public function get_session_user()
	{
		if (!empty(session()->username)) {
			return $this->get_userinfo_by_username(session()->username);
		} else {
			return false;
		}
	}

	public function get_user($id)
	{
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->select('*');
		$builder->where('id', $id);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function get_all_users()
	{
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->select('*');
		$builder->orderBy("name", "asc");
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function get_worker_projects_from_userid($id)
	{
		$db = db_connect();
		$builder = $db->table('t_prj');
		$builder->select('t_prj.name,t_prj.id as proje_id');
		$builder->join('t_prj_cntct_prsnl', 't_prj_cntct_prsnl.prj_id = t_prj.id');
		$builder->join('t_user', 't_user.id = t_prj_cntct_prsnl.usr_id');
		$builder->where('t_user.id', $id);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function deneme_json($id)
	{
		$db = db_connect();
		$builder = $db->table('t_prj');
		$builder->select('t_prj.name as text,t_prj.id as id');
		$builder->join('t_prj_cnsltnt', 't_prj_cnsltnt.prj_id = t_prj.id');
		$builder->join('t_user', 't_user.id = t_prj_cnsltnt.cnsltnt_id');
		$builder->where('t_user.id', $id);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function get_consultant_projects_from_userid($id)
	{
		$db = db_connect();
		$builder = $db->table('t_prj');
		$builder->select('t_prj.name,t_prj.id as proje_id');
		$builder->join('t_prj_cnsltnt', 't_prj_cnsltnt.prj_id = t_prj.id');
		$builder->join('t_user', 't_user.id = t_prj_cnsltnt.cnsltnt_id');
		$builder->where('t_user.id', $id);
		$builder->orderBy('t_prj.name', 'ASC');
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function update_user($update)
	{
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->replace($update);
	}

	public function make_user_consultant($id, $username = FALSE)
	{
		if (empty($username)) {
			$username = "Username";
		}
		// T_cnsltnt array
		$data = array(
			'user_id' => $id,
			'description' => $username,
			'active' => '1'
		);
		$db = db_connect();
		$builder = $db->table('t_cnsltnt');
		$builder->insert($data);

		// T_USER array
		$data = array(
			'role_id' => '1',
			'id' => $id
		);
		$builder = $db->table('t_user');
		$builder->update($data);
	}

	public function is_user_consultant($id)
	{
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->select('*');
		$builder->where('id', $id);
		$query = $builder->get()->getRowArray();
		if ($query['role_id'] == "1") {
			return TRUE;
		} else {
			return FALSE;
		}
	}

	public function set_user_image($userId, $photo)
	{
		$db = db_connect();
		$data = array(
			'photo' => $photo,
			'id' => $userId
		);
		$builder = $db->table('t_user');
		$builder->update($data);
	}

	public function users_without_company()
	{
		$db = db_connect();
		$builder = $db->table('t_user');
		$builder->select('*');
		$builder->where('`id` NOT IN (SELECT `user_id` FROM `t_cmpny_prsnl`)', NULL, FALSE);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function do_consultant($id)
	{
		$db = db_connect();
		$builder = $db->table('t_role');
		$builder->select('t_role.short_code');
		$builder->join('t_user', 't_user.role_id = t_role.id');
		$builder->where('t_user.id', $id);
		$query = $builder->get();
		return $query->getRowArray();
	}

	//Bir danışmanın danışman olduğu şirketleri listeler
	public function do_edit_company_consultant($user_id)
	{
		$db = db_connect();
		$builder = $db->table('t_prj_cnsltnt');
		$builder->select('t_prj_cmpny.cmpny_id as cmpnyID');
		$builder->join('t_prj_cmpny', 't_prj_cmpny.prj_id = t_prj_cnsltnt.prj_id');
		$builder->where('t_prj_cnsltnt.cnsltnt_id', $user_id);
		$query = $builder->get();
		return $query->getResultArray();
	}

	public function is_consultant_of_company_by_user_id($user_id, $company_id)
	{
		$db = db_connect();
		$builder = $db->table('t_prj_cnsltnt');
		$builder->select('t_prj_cmpny.cmpny_id as cmpnyID');
		$builder->join('t_prj_cmpny', 't_prj_cmpny.prj_id = t_prj_cnsltnt.prj_id');
		$builder->where('t_prj_cnsltnt.cnsltnt_id', $user_id);
		$builder->where('t_prj_cmpny.cmpny_id', $company_id);
		$query = $builder->get()->getResultArray();
		if (empty($query)) {
			return FALSE;
		} else {
			return TRUE;
		}
	}

	public function is_consultant_of_project_by_user_id($user_id, $prj_id)
	{
		$db = db_connect();
		$builder = $db->table('t_prj_cnsltnt');
		$builder->select('*');
		$builder->where('t_prj_cnsltnt.cnsltnt_id', $user_id);
		$builder->where('t_prj_cnsltnt.prj_id', $prj_id);
		$query = $builder->get()->getResultArray();
		if (empty($query)) {
			return FALSE;
		} else {
			return TRUE;
		}
	}

	public function is_contactperson_of_project_by_user_id($user_id, $prj_id)
	{
		$db = db_connect();
		$builder = $db->table('t_prj_cntct_prsnl');
		$builder->select('*');
		$builder->where('t_prj_cntct_prsnl.usr_id', $user_id);
		$builder->where('t_prj_cntct_prsnl.prj_id', $prj_id);
		$query = $builder->get()->getResultArray();
		if (empty($query)) {
			return FALSE;
		} else {
			return TRUE;
		}
	}

	public function cmpny_prsnl($user_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cmpny_prsnl');
		$builder->select('cmpny_id');
		$builder->where('user_id', $user_id);
		$query = $builder->get();
		return $query->getRowArray();
	}

	public function is_contact_by_userid($user_id, $company_id)
	{
		$db = db_connect();
		$builder = $db->table('t_cmpny_prsnl');
		$builder->select('*');
		$builder->where('user_id', $user_id);
		$builder->where('cmpny_id', $company_id);
		$builder->where('is_contact', '1');
		$query = $builder->get()->getRowArray();
		if (empty($query))
			return FALSE;
		else
			return TRUE;
	}

	//TODO: check if it creates security issues. Bypass for admins.
	public function is_admin($user_id)
	{
		if ($user_id == 1 || $user_id == 48290) return TRUE;
	}

	//verilen user'ın verilen şirketi edit edip edemeyeceğine dair bilgiyi verir
	public function can_edit_company($user_id, $company_id)
	{
		if ($this->is_admin($user_id)) return TRUE;
		$consultant = $this->is_consultant_of_company_by_user_id($user_id, $company_id);
		$contact = $this->is_contact_by_userid($user_id, $company_id);
		return $consultant || $contact;
	}

	public function create_dataset_for_users($data)
	{
		$db = db_connect();
		$builder = $db->table('t_users_data');
		$builder->insert($data);
		return $db->insertID();
	}
}
