<?php
namespace App\Models;

use CodeIgniter\Model;

class Company_model extends Model
{

    public function __construct()
    {
        $db = db_connect();
    }

    public function insert_company($data)
    {
        $db->insert('t_cmpny', $data);
        $db->select('id');
        $db->from('t_cmpny');
        $db->where('name', $data['name']);
        $query = $db->get()->row_array();
        return $query['id'];
    }

    /**
     * Saves company icon information
     * @param [compnay id]
     * @param [logo address]
     */
    public function set_company_image($last_id, $logo)
    {
        $db->where('id', $last_id);
        $db->update('t_cmpny', $logo);
    }

    public function search_nace_code($code)
    {
        $db->select('id');
        $db->from('t_nace_code_rev2');
        $db->where('code', $code);
        $query = $db->get()->row_array();
        return $query;
    }

    public function insert_cmpny_nace_code($data)
    {
        $db->insert('t_cmpny_nace_code', $data);
    }

    public function get_companies()
    {
        $db->select('id,name,latitude,longitude,description');
        $db->from('t_cmpny');
        $db->order_by("name", "asc");
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function get_my_companies($user_id)
    {
        $db->select('*');
        $db->from('t_cmpny');
        $db->join('t_cmpny_prsnl', 't_cmpny_prsnl.cmpny_id = t_cmpny.id');
        $db->where('t_cmpny_prsnl.user_id', $user_id);
        $db->order_by("name", "asc");
        $query = $db->get();
        return $$query->getResultArray();
    }

    /**
     * returns all companies that user have permission on
     * @param  [type] $user_id [user id]
     * @return [type]          [companies information array]
     */
    public function get_all_companies_i_have_rights($user_id)
    {
        $db->select('DISTINCT ON (t_cmpny.name) *', false);
        $db->from('t_cmpny');
        $db->join('t_cmpny_prsnl', 't_cmpny_prsnl.cmpny_id = t_cmpny.id', 'left');

        $db->join('t_prj_cmpny', 't_prj_cmpny.cmpny_id = t_cmpny.id', 'left');
        $db->join('t_prj_cnsltnt', 't_prj_cnsltnt.prj_id = t_prj_cmpny.prj_id', 'left');

        $db->where('t_cmpny_prsnl.user_id', $user_id);
        $db->or_where('t_prj_cnsltnt.cnsltnt_id', $user_id);

        $db->order_by("t_cmpny.name", "asc");

        $query = $db->get();
        return $$query->getResultArray();
    }

    public function get_project_companies($project_id)
    {
        $db->select('*');
        $db->from('t_cmpny');
        $db->join('t_prj_cmpny', 't_prj_cmpny.cmpny_id = t_cmpny.id');
        $db->where('t_prj_cmpny.prj_id', $project_id);
        $db->order_by("name", "asc");
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function get_company($id)
    {
        $db->select('*');
        $query = $db->get_where('t_cmpny', array('id' => $id));
        return $query->row_array();
    }

    public function get_nace_code($id)
    {
        $db->select('t_nace_code_rev2.code, t_nace_code_rev2.name');
        $db->from('t_nace_code_rev2');
        $db->join('t_cmpny_nace_code', 't_cmpny_nace_code.nace_code_id = t_nace_code_rev2.id', 'left');
        $db->join('t_cmpny', 't_cmpny.id = t_cmpny_nace_code.cmpny_id', 'left');
        $db->where('t_cmpny.id', $id);
        $query = $db->get();
        return $query->row_array();
    }

    public function get_all_nace_codes()
    {
        $db->select('t_nace_code_rev2.code');
        $db->order_by('t_nace_code_rev2.code', 'asc');
        $db->from('t_nace_code_rev2');
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function get_countries()
    {
        $db->select('gis_world.id,gis_world.country_name');
        $db->order_by('gis_world.country_name', 'asc');
        $db->from('gis_world');
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function get_company_proj($id)
    {
        $db->select('t_prj.name,t_prj.id as proje_id');
        $db->from('t_prj');
        $db->join('t_prj_cmpny', 't_prj_cmpny.prj_id = t_prj.id');
        $db->join('t_cmpny', 't_cmpny.id = t_prj_cmpny.cmpny_id');
        $db->where('t_cmpny.id', $id);
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function get_company_workers($id)
    {
        $db->select('t_user.name,t_user.surname,t_user.id,t_user.user_name');
        $db->from('t_user');
        $db->join('t_cmpny_prsnl', 't_cmpny_prsnl.user_id = t_user.id');
        $db->join('t_cmpny', 't_cmpny.id = t_cmpny_prsnl.cmpny_id');
        $db->where('t_cmpny.id', $id);
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function company_search($q)
    {
        $db->select('t_cmpny.name,t_cmpny.id');
        $db->from('t_cmpny');
        $db->like('name', $q);
        $query = $db->get();
        if ($query->num_rows > 0) {
            foreach ($query->result_array() as $row) {
                $new_row['label'] = htmlentities(stripslashes($row['name']));
                $new_row['value'] = htmlentities(stripslashes($row['id']));
                $row_set[]        = $new_row; //build an array
            }
            return json_encode($row_set); //format the array into json data
        }
    }

    public function update_company($data, $id)
    {
        $db->where('id', $id);
        $db->update('t_cmpny', $data);
    }

    public function update_cmpny_data($data, $id)
    {
        $db->where('cmpny_id', $id);
        $db->update('t_cmpny_data', $data);
    }

    public function update_cmpny_nace_code($data, $id)
    {
        $db->where('cmpny_id', $id);
        $db->update('t_cmpny_nace_code', $data);
    }

    public function unique_control_email($email, $cmpny_id)
    {
        $db->select('id');
        $db->from('t_cmpny');
        $db->where('email', $email);
        $query = $db->get()->result_array();
        if (empty($query)) {
            return true;
        } else {
            foreach ($query as $variable) {
                if ($variable['id'] != $cmpny_id) {
                    return false;
                }

            }
            return true;
        }
    }

    public function insert_cmpny_prsnl($cmpny_id)
    {
        $tmp  = $session->get('user_in');
        $data = array(
            'user_id'    => $tmp['id'],
            'cmpny_id'   => $cmpny_id,
            'is_contact' => '1',
        );
        $db->insert('t_cmpny_prsnl', $data);
    }

    public function update_cmpny_prsnl($user_id, $cmpny_id, $data)
    {
        $db->where('user_id', $user_id);
        $db->where('cmpny_id', $cmpny_id);
        $db->update('t_cmpny_prsnl', $data);
    }

    public function return_email($id)
    {
        $db->select('email');
        $db->from('t_cmpny');
        $db->where('id', $id);
        $query = $db->get();
        return $$query->getResultArray();
    }

    public function count_company_table()
    {
        $count = $db->table('t_cmpny')->countAll();
        return $count;
    }

    public function add_worker_to_company($user)
    {
        $db->insert('t_cmpny_prsnl', $user);
    }

    public function remove_worker_to_company($user)
    {
        $db->where('user_id', $user['user_id']);
        $db->where('cmpny_id', $user['cmpny_id']);
        $db->where('is_contact', '0');
        $db->delete('t_cmpny_prsnl');
    }

    public function is_in_nace($nace)
    {
        $query = $db->get_where('t_nace_code_rev2', array('code' => $nace))->row_array();
        if (empty($query)) {
            return false;
        } else {
            return true;
        }

    }

    public function get_clusters()
    {
        $db->select('*');
        $db->from('t_clstr');
        $query = $db->get()->result_array();
        return $query;
    }

    public function get_companies_with_cluster($cluster_id)
    {
        $db->select('*');
        $db->from('t_cmpny');
        $db->join('t_cmpny_clstr', 't_cmpny_clstr.cmpny_id = t_cmpny.id');
        $db->where('t_cmpny_clstr.clstr_id', $cluster_id);
        $query = $db->get()->result_array();
        return $query;
    }

    public function get_companies_from_flow($flow_id)
    {
        $db->select('*,t_cmpny.id as id');
        $db->from('t_cmpny');
        $db->join('t_cmpny_flow', 't_cmpny_flow.cmpny_id = t_cmpny.id');

        if( strpos( $flow_id, "-" ) !== false) {
            $flow_array = explode('-', $flow_id);
            foreach ($flow_array as $fi){
                $db->or_where('t_cmpny_flow.flow_id', $fi);
            }
        }else{
            $db->where('t_cmpny_flow.flow_id', $flow_id);
        }

        $db->distinct();

        $query = $db->get()->result_array();
        return $query;
    }

    public function have_project_name($cmpny_id, $cmpny_name)
    {
        $db->select('id');
        $db->from('t_cmpny');
        $db->where('name', $cmpny_name);
        $query = $db->get()->result_array();
        if (empty($query)) {
            return true;
        } else {
            foreach ($query as $variable) {
                if ($variable['id'] != $cmpny_id) {
                    return false;
                }
            }
            return true;
        }
    }

    //company delete model
    public function delete_company($cmpny_id)
    {
        //deletes the company from clusters table
        $db->where('cmpny_id', $cmpny_id);
        $db->delete('t_cmpny_clstr');

        //deletes the company from NACE codes table
        $db->where('cmpny_id', $cmpny_id);
        $db->delete('t_cmpny_nace_code');

        //deletes the company from t_cmpny_prsnl table
        $db->where('cmpny_id', $cmpny_id);
        $db->delete('t_cmpny_prsnl');

        //deletes the company from project table
        $db->where('cmpny_id', $cmpny_id);
        $db->delete('t_prj_cmpny');

        //deletes the company from company flow component table
        $db->select('id');
        $db->from('t_cmpnnt');
        $db->where('cmpny_id', $cmpny_id);
        $query = $db->get()->result_array();
        if(!empty($query)){
            $db->where_in('cmpnnt_id', $query);
            $db->delete('t_cmpny_flow_cmpnnt');
        }

        // //deletes the company from component table
        $db->where('cmpny_id', $cmpny_id);
        $db->delete('t_cmpnnt');

        //deletes the company from company process equipment table
        $db->select('id');
        $db->from('t_cmpny_eqpmnt');
        $db->where('cmpny_id', $cmpny_id);
        $query = $db->get()->result_array();
        if(!empty($query)){
            $db->where_in('cmpny_eqpmnt_type_id', $query);
            $db->delete('t_cmpny_prcss_eqpmnt_type');
        }
        
        //deletes the company from equipment table
        $db->where('cmpny_id', $cmpny_id);
        $db->delete('t_cmpny_eqpmnt');
        
        //deletes the company from company table
        $db->where('id', $cmpny_id);
        $db->delete('t_cmpny');


    }

}
