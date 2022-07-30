<?php

namespace App\Controllers;

class Isscoping extends BaseController
{

    public function index()
    {
        //print_r($this->session->username);
        if (isset($this->session->username)) {
            if (empty($this->session->username)) {
                return redirect()->to(site_url('login'));
            }
        } else {
            return redirect()->to(site_url('login'));
        }

        if (isset($this->session->role_id)) {
            if (($this->session->role_id == null || $this->session->role_id == '')
                || $this->session->role_id != '3') {
               return redirect()->to(site_url('company'));
            }
        } else {
           return redirect()->to(site_url('company'));
        }

        echo view('template/header');
        echo view('isscoping/index');
        echo view('template/footer');
    }

    public function auto()
    {
        
        //print_r($this->session->username);
        $data['userID'] = $this->session->id;

        if (isset($this->session->username)) {
            if (empty($this->session->username)) {
                return redirect()->to(site_url('login'));
            }
        } else {
            return redirect()->to(site_url('login'));
        }

        if (isset($this->session->role_id)) {
            if (($this->session->role_id == null || $this->session->role_id == '')
                || $this->session->role_id != '3') {
               return redirect()->to(site_url('company'));
            }
        } else {
           return redirect()->to(site_url('company'));
        }

        echo view('template/header');
        echo view('isscoping/auto', $data);
        echo view('template/footer');
    }

    public function autoprjbaseMDF()
    {
		$company_model = model(Company_model::class);

        if (isset($this->session->username)) {
            if (empty($this->session->username)) {
                return redirect()->to(site_url('login'));
            }
        } else {
            return redirect()->to(site_url('login'));
        }

        if (isset($this->session->get('project_id'))) {
            if ($this->session->get('project_id') == null || $this->session->get('project_id') == '') {
                return redirect()->to(site_url('projects'));
            }
        } else {
            return redirect()->to(site_url('projects'));
        }

        if (isset($this->session->role_id)) {
            if (($this->session->role_id == null || $this->session->role_id == '')
                || $this->session->role_id != 1) {
               return redirect()->to(site_url('company'));
            }
        } else {
           return redirect()->to(site_url('company'));
        }

        $project_id = $this->session->get('project_id');

        $data['companies'] = $company_model->get_project_companies($project_id);
        $data['userID']     = $this->session->id;
        $data['project_id'] = $this->session->get('project_id');
        
        echo view('template/header');
        echo view('isscoping/autoprojectbaseMDF', $data);
        echo view('template/footer');
    }

    public function autoprjbaseMDFTest()
    {
        //print_r('zeynel');
        //print_r($this->session->username);
        //print_r($session->get);
        if (isset($this->session->username)) {
            if (empty($this->session->username)) {
                return redirect()->to(site_url('login'));
            }
        } else {
            return redirect()->to(site_url('login'));
        }

        if (isset($this->session->get('project_id'))) {
            if ($this->session->get('project_id') == null || $this->session->get('project_id') == '') {
                return redirect()->to(site_url('projects'));
            }
        } else {
            return redirect()->to(site_url('projects'));
        }

        if (isset($this->session->role_id)) {
            if (($this->session->role_id == null || $this->session->role_id == '')
                || $this->session->role_id != 1) {
               return redirect()->to(site_url('company'));
            }
        } else {
           return redirect()->to(site_url('company'));
        }

        $data['userID']     = $this->session->id;
        $data['project_id'] = $this->session->get('project_id');
        echo view('template/header');
        echo view('isscoping/autoprojectbaseMDF_test', $data);
        echo view('template/footer');
    }

    public function autoprjbase()
    {
        //print_r('zeynel');
        //print_r($this->session->username);
        //print_r($session->get);
        if (isset($this->session->username)) {
            if (empty($this->session->username)) {
                return redirect()->to(site_url('login'));
            }
        } else {
            return redirect()->to(site_url('login'));
        }

        if (isset($this->session->get('project_id'))) {
            if ($this->session->get('project_id') == null || $this->session->get('project_id') == '') {
                return redirect()->to(site_url('projects'));
            }
        } else {
            return redirect()->to(site_url('projects'));
        }

        if (isset($this->session->role_id)) {
            if (($this->session->role_id == null || $this->session->role_id == '')
                || $this->session->role_id != 1) {
               return redirect()->to(site_url('company'));
            }
        } else {
           return redirect()->to(site_url('company'));
        }

        $data['userID']     = $this->session->id;
        $data['project_id'] = $this->session->get('project_id');
        echo view('template/header');
        echo view('isscoping/autoprojectbase', $data);
        echo view('template/footer');
    }

    public function prjbaseMDF()
    {
        $company_model = model(Company_model::class);

        //print_r($session->get);
        //print_r($this->session->id);
        if (isset($this->session->username)) {
            if (empty($this->session->username)) {
                return redirect()->to(site_url('login'));
            }
        } else {
            return redirect()->to(site_url('login'));
        }

        if (isset($this->session->get('project_id'))) {
            if ($this->session->get('project_id') == null || $this->session->get('project_id') == '') {
                return redirect()->to(site_url('projects'));
            }
        } else {
            return redirect()->to(site_url('projects'));
        }

        if (isset($this->session->role_id)) {
            if (($this->session->role_id == null || $this->session->role_id == '')
                || $this->session->role_id != 1) {
               return redirect()->to(site_url('company'));
            }
        } else {
           return redirect()->to(site_url('company'));
        }


        $project_id = $this->session->get('project_id');

        $data['companies'] = $company_model->get_project_companies($project_id);
        $data['userID']     = $this->session->id;
        $data['project_id'] = $this->session->get('project_id');
        
        echo view('template/header');
        echo view('isscoping/projectbaseMDF', $data);
        echo view('template/footer');
    }

    public function prjbase()
    {
        //print_r($session->get);
        //print_r($this->session->id);
        if (isset($this->session->username)) {
            if (empty($this->session->username)) {
                return redirect()->to(site_url('login'));
            }
        } else {
            return redirect()->to(site_url('login'));
        }

        if (isset($this->session->get('project_id'))) {
            if ($this->session->get('project_id') == null || $this->session->get('project_id') == '') {
                return redirect()->to(site_url('projects'));
            }
        } else {
            return redirect()->to(site_url('projects'));
        }

        if (isset($this->session->role_id)) {
            if (($this->session->role_id == null || $this->session->role_id == '')
                || $this->session->role_id != 1) {
               return redirect()->to(site_url('company'));
            }
        } else {
           return redirect()->to(site_url('company'));
        }

        $data['userID']     = $this->session->id;
        $data['project_id'] = $this->session->get('project_id');
        echo view('template/header');
        echo view('isscoping/projectbase', $data);
        echo view('template/footer');
    }

    public function tooltip()
    {
        //echo view('template/header');
        echo view('isscoping/tooltip');
        //echo view('template/footer');
    }

    public function tooltipscenarios()
    {
        //echo view('template/header');
        echo view('isscoping/tooltipscenarios');
        //echo view('template/footer');
    }

    public function isscenarios()
    {
        $company_model = model(Company_model::class);

        if (isset($this->session->username)) {
            if (empty($this->session->username)) {
                return redirect()->to(site_url('login'));
            }
        } else {
            return redirect()->to(site_url('login'));
        }

        if (isset($this->session->get('project_id'))) {
            if ($this->session->get('project_id') == null || $this->session->get('project_id') == '') {
                return redirect()->to(site_url('projects'));
            }
        } else {
            return redirect()->to(site_url('projects'));
        }

        if (isset($this->session->role_id)) {
            if (($this->session->role_id == null || $this->session->role_id == '')
                || $this->session->role_id != 1) {
               return redirect()->to(site_url('company'));
            }
        } else {
           return redirect()->to(site_url('company'));
        }


        $project_id = $this->session->get('project_id');

        $data['companies'] = $company_model->get_project_companies($project_id);
        $data['userID']     = $this->session->id;
        $data['project_id'] = $this->session->get('project_id');
        
        echo view('template/header');
        echo view('isscoping/isscenarios', $data);
        echo view('template/footer');
    }

    public function isscenariosCns()
    {
        $company_model = model(Company_model::class);

        if (isset($this->session->username)) {
            if (empty($this->session->username)) {
                return redirect()->to(site_url('login'));
            }
        } else {
            return redirect()->to(site_url('login'));
        }

        if (isset($this->session->get('project_id'))) {
            if ($this->session->get('project_id') == null || $this->session->get('project_id') == '') {
                return redirect()->to(site_url('projects'));
            }
        } else {
            return redirect()->to(site_url('projects'));
        }

        if (isset($this->session->role_id)) {
            if (($this->session->role_id == null || $this->session->role_id == '')
                || $this->session->role_id != 1) {
               return redirect()->to(site_url('company'));
            }
        } else {
           return redirect()->to(site_url('company'));
        }

        
        $project_id = $this->session->get('project_id');

        $data['companies'] = $company_model->get_project_companies($project_id);
        $data['userID']     = $this->session->id;
        $data['project_id'] = $this->session->get('project_id');
        
        echo view('template/header');
        echo view('isscoping/isscenariosCns', $data);
        echo view('template/footer');
    }

}
