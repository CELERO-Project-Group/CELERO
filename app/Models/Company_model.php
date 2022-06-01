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
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->insert($data);
        return $db->insertID();
    }

    public function search_nace_code($code)
    {
        $db = db_connect();
        $builder = $db->table('t_nace_code_rev2');
        $builder->select('id');
        $builder->where('code', $code);
        $query = $builder->get();
        return $query->getRowArray();
    }

    public function insert_cmpny_nace_code($data)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny_nace_code');
        $builder->insert($data);
        return $db->insertID();
    }

    public function get_companies()
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select('id,name,latitude,longitude,description');
        $builder->orderBy("name", "asc");
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function get_my_companies($user_id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select("*");
        $builder->join('t_cmpny_prsnl', 't_cmpny_prsnl.cmpny_id = t_cmpny.id');
        $builder->where('t_cmpny_prsnl.user_id', $user_id);
        $builder->orderBy("name", "asc");
        $query = $builder->get();
        return $query->getResultArray();
    }

    /**
     * returns all companies that user have permission on
     * @param  [type] $user_id [user id]
     * @return [type]          [companies information array]
     */
    public function get_all_companies_i_have_rights($user_id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select('DISTINCT ON (t_cmpny.name) *', false);
        $builder->join('t_cmpny_prsnl', 't_cmpny_prsnl.cmpny_id = t_cmpny.id', 'left');
        $builder->join('t_prj_cmpny', 't_prj_cmpny.cmpny_id = t_cmpny.id', 'left');
        $builder->join('t_prj_cnsltnt', 't_prj_cnsltnt.prj_id = t_prj_cmpny.prj_id', 'left');
        $builder->where('t_cmpny_prsnl.user_id', $user_id);
        $builder->orWhere('t_prj_cnsltnt.cnsltnt_id', $user_id);
        $builder->orderBy('t_cmpny.name', 'asc');
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function get_project_companies($project_id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select("*");
        $builder->join('t_prj_cmpny', 't_prj_cmpny.cmpny_id = t_cmpny.id');
        $builder->where('t_prj_cmpny.prj_id', $project_id);
        $builder->orderBy("name", "asc");
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function get_company($id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select("*");
        $builder->where("id", $id);
        $query = $builder->get();
        return $query->getRowArray();
    }

    public function get_nace_code($id)
    {
        $db = db_connect();
        $builder = $db->table('t_nace_code_rev2');
        $builder->select("t_nace_code_rev2.code, t_nace_code_rev2.name");
        $builder->join('t_cmpny_nace_code', 't_cmpny_nace_code.nace_code_id = t_nace_code_rev2.id', 'left');
        $builder->join('t_cmpny', 't_cmpny.id = t_cmpny_nace_code.cmpny_id', 'left');
        $builder->where('t_cmpny.id', $id);
        $query = $builder->get();
        return $query->getRowArray();
    }

    public function get_all_nace_codes()
    {
        $db = db_connect();
        $builder = $db->table('t_nace_code_rev2');
        $builder->select('t_nace_code_rev2.code');
        $builder->orderBy('t_nace_code_rev2.code', 'asc');
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function get_countries()
    {
        return array("Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo", "Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia (Hrvatska)", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)", "Faroe Islands", "Fiji", "Finland", "France", "France Metropolitan", "French Guiana", "French Polynesia", "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Heard and Mc Donald Islands", "Holy See (Vatican City State)", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran (Islamic Republic of)", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kuwait", "Kyrgyzstan", "Lao, People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia, The Former Yugoslav Republic of", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of", "Monaco", "Mongolia", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Seychelles", "Sierra Leone", "Singapore", "Slovakia (Slovak Republic)", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "St. Helena", "St. Pierre and Miquelon", "Sudan", "Suriname", "Svalbard and Jan Mayen Islands", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic", "Taiwan, Province of China", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Virgin Islands (British)", "Virgin Islands (U.S.)", "Wallis and Futuna Islands", "Western Sahara", "Yemen", "Yugoslavia", "Zambia", "Zimbabwe");
    }

    public function get_company_proj($id)
    {
        $db = db_connect();
        $builder = $db->table('t_prj');
        $builder->select("t_prj.name,t_prj.id as proje_id");
        $builder->join('t_prj_cmpny', 't_prj_cmpny.prj_id = t_prj.id');
        $builder->join('t_cmpny', 't_cmpny.id = t_prj_cmpny.cmpny_id');
        $builder->where('t_cmpny.id', $id);
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function get_company_workers($id)
    {
        $db = db_connect();
        $builder = $db->table('t_user');
        $builder->select("t_user.name,t_user.surname,t_user.id,t_user.user_name");
        $builder->join('t_cmpny_prsnl', 't_cmpny_prsnl.user_id = t_user.id');
        $builder->join('t_cmpny', 't_cmpny.id = t_cmpny_prsnl.cmpny_id');
        $builder->where('t_cmpny.id', $id);
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function company_search($q)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select("t_cmpny.name,t_cmpny.id");
        $builder->like('name', $q);
        $query = $builder->get();
        if ($query->num_rows > 0) {
            foreach ($query->getResultArray() as $row) {
                $new_row['label'] = htmlentities(stripslashes($row['name']));
                $new_row['value'] = htmlentities(stripslashes($row['id']));
                $row_set[]        = $new_row; //build an array
            }
            return json_encode($row_set); //format the array into json data
        }
    }

    public function update_company($data, $id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->where('id', $id);
        $builder->update($data);
    }

    public function update_cmpny_data($data, $id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny_data');
        $builder->where('cmpny_id', $id);
        $builder->update($data);
    }

    public function update_cmpny_nace_code($data, $id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny_nace_code');
        $builder->where('cmpny_id', $id);
        $builder->update($data);
    }

    public function unique_control_email($email, $cmpny_id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select("id");
        $builder->where('email', $email);
        $query = $builder->get()->getResultArray();
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

    public function insert_cmpny_prsnl($companyOwner)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny_prsnl');
        $builder->insert($companyOwner);
        return $db->insertID();
    }

    public function update_cmpny_prsnl($user_id, $cmpny_id, $data)
    {
        $db->where('user_id', $user_id);
        $db->where('cmpny_id', $cmpny_id);
        $db->update('t_cmpny_prsnl', $data);
    }

    public function return_email($id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select('email');
        $builder->where('id', $id);
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function count_company_table()
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select('id');
        $count = $builder->countAll();
        return $count;
    }

    public function add_worker_to_company($user)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny_prsnl');
        $builder->insert($user);
        return $db->insertID();
    }

    public function remove_worker_to_company($user)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny_prsnl');
        $builder->where('user_id', $user['user_id']);
        $builder->where('cmpny_id', $user['cmpny_id']);
        $builder->where('is_contact', '0');
        $builder->delete();
    }

    public function is_in_nace($nace)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select("*");
        $builder->where("id", $id);
        $query = $builder->get();

        $query = $query->getRowArray();
        if (empty($query)) {
            return false;
        } else {
            return true;
        }
    }

    public function get_clusters()
    {
        $db = db_connect();
        $builder = $db->table('t_clstr');
        $builder->select('*');
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function get_companies_with_cluster($cluster_id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select('*');
        $builder->join('t_cmpny_clstr', 't_cmpny_clstr.cmpny_id = t_cmpny.id');
        $builder->where('t_cmpny_clstr.clstr_id', $cluster_id);
        $query = $builder->get();
        return $query->getResultArray();
    }

    public function get_companies_from_flow($flow_id)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select('*,t_cmpny.id as id');
        $builder->join('t_cmpny_flow', 't_cmpny_flow.cmpny_id = t_cmpny.id');

        if (strpos($flow_id, "-") !== false) {
            $flow_array = explode('-', $flow_id);
            foreach ($flow_array as $fi) {
                $builder->orWhere('t_cmpny_flow.flow_id', $fi);
            }
        } else {
            $builder->where('t_cmpny_flow.flow_id', $flow_id);
        }

        $builder->distinct();

        $query = $builder->get();
        return $query->getResultArray();
    }

    public function have_project_name($cmpny_id, $cmpny_name)
    {
        $db = db_connect();
        $builder = $db->table('t_cmpny');
        $builder->select('id');
        $builder->where('name', $cmpny_name);
        $query = $builder->get()->getResultArray();

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
    // TODO
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
        if (!empty($query)) {
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
        if (!empty($query)) {
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
