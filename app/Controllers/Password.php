<?php

namespace App\Controllers;
use App\Models\Password_model;

class Password extends BaseController {

	public function send_email_for_change_pass(){
		$password_model = model(Password_model::class);

		$validation = \Config\Services::validation();

		$this->validate([
			'old_pass' => [
				'rules' => 'trim|required',
				'label' => 'Old Password'
			],
			'new_pass' => [
				'rules' => 'trim|required|callback_password_check',
				'label' => 'New Password'
			],
			'new_pass_again' => [
				'rules' => 'trim|required',
				'label' => 'New Password (Again)'
			]
			
		]);

		if ($validation->withRequest($this->request)->run() !== FALSE) {
			$userId = $this->session->id;
			$pass = md5($this->request->getPost('old_pass'));
			if($password_model->do_similar_pass($userId,$pass)){
				$data = array(
						'psswrd' => md5($this->request->getPost('new_pass'))
					);
				$password_model->change_pass($userId,$data);
				redirect('send_email_for_change_pass','refresh');
			}
		}
		echo view('template/header');
		echo view('password/send_email_for_change_pass');
		echo view('template/footer');
	}

	public function change_pass($rnd_str){
		$password_model = model(Password_model::class);

		$random = $rnd_str = $this->uri->segment(2);

		if($password_model->click_control($random) == true){

			$this->form_validation->set_rules('old_pass', 'Old Password', 'trim|xss_clean|required');
			$this->form_validation->set_rules('new_pass', 'New Password', 'trim|xss_clean|required|callback_password_check');
			$this->form_validation->set_rules('new_pass_again', 'New Password Again', 'trim|xss_clean|required');

			if ($this->form_validation->run() !== FALSE){

				$user_id = $password_model->get_user_id($random);

				$old_pass = $this->request->getPost('old_pass');
				$new_pass = $this->request->getPost('new_pass');
				if($password_model->do_similar_pass($user_id,md5($old_pass)) == true){
					$control = array(
							'psswrd' => md5($new_pass)
						);
					$password_model->change_pass($user_id,$control);
				}

				$message = 'Your password has been changed. Your new password is: '.$new_pass;
				$email = $password_model->get_email($user_id);

				$send_email = array(
						'message' => $message,
						'email' => $email
					);
				$mailCheck = $this->sendMAil($send_email);

				$rnd_str = array(
					'random_string' => null,
					'click_control' => 0
				);
				$password_model->set_random_string_zero($random,$rnd_str);

				redirect('login','refresh');
			}

			$data = array(
				'random_string' => $random
			);

			echo view('template/header');
			echo view('password/change_pass',$data);
			echo view('template/footer');
		}
		else{
			return redirect()->back();
		}
	}

	public function new_password_email(){
		$password_model = model(Password_model::class);
		$validation = \Config\Services::validation();

		$this->validate([
			'email' => [
				'rules' => 'trim|required',
				'label' => 'E-mail'
			],
		]);

		if ($validation->withRequest($this->request)->run() !== FALSE) {

			$email = $this->request->getPost('email');

			$user_id = $password_model->get_id($email);

			$random_str = $this->generateRandomString();
			$asd = base_url("new_password/".$random_str);

			$message = '<a href='.$asd.'>Change Password</a>';

			$rnd_str = array(
					'random_string' => $random_str,
					'click_control' => 1
				);
			$password_model->set_random_string($user_id,$rnd_str);

			$data = array(
					'message' => $message,
					'email' => $email
				);
			$this->sendMAil($data);
			return redirect()->back();
		}
		echo view('template/header');
		echo view('password/new_password_email');
		echo view('template/footer');
	}

	public function new_password($rnd_string){
		$password_model = model(Password_model::class);

		$user_id = $password_model->get_user_id($rnd_string);
		if(isset($user_id)){
			$data['random_string'] = $rnd_string;

			$this->form_validation->set_rules('new_pass', 'New Password', 'trim|xss_clean|required');
			$this->form_validation->set_rules('new_pass_again', 'New Password(Again)', 'trim|xss_clean|required');

			if ($this->form_validation->run() !== FALSE){
				if($this->password_check() == true){
					$new_pass = $this->request->getPost('new_pass');
					$control = array(
						'psswrd' => md5($new_pass)
					);
					$password_model->change_pass($user_id,$control);

					$message = 'Your password has been changed. Your new password is: '.$new_pass;
					$email = $password_model->get_email($user_id);

					$send_email = array(
						'message' => $message,
						'email' => $email
					);
					$mailCheck = $this->sendMAil($send_email);

					$rnd_str = array(
						'random_string' => null,
						'click_control' => 0
					);
											
											if($mailCheck) {
													$message = 'Your mail has been sent.';
											} else {
													$message = 'Your mail has not been sent.You could not change password';
											}
											$password_model->set_random_string_zero($rnd_string,$rnd_str);
											$data['success'] = $message;
					//redirect('login','refresh');
				}
			}

			echo view('template/header');
			echo view('password/new_pass',$data);
			echo view('template/footer');
		}else{
			echo "Wrong pass number.";
		}
	}

	// sends mail to user. We need to change this settings.
	public function sendMail($data)
	{
		$email = \Config\Services::email();
		
		$config = Array(
		  'protocol' => 'smtp',
		  'smtp_host' => 'ssl://smtp.googlemail.com',
		  'smtp_port' => 465,
		  'smtp_user' => 'celero.info@gmail.com', // change it to yours
		  'smtp_pass' => '8dwa9z&*', // change it to yours
		  'mailtype' => 'html',
		  'charset' => 'iso-8859-1',
		  'wordwrap' => TRUE
		);

		//config should be set.
		$email = service('email');
		$email->setFrom('celero.info@gmail.com', 'Celero Project');
		$email->setTo($data['email']);
		$email->setSubject('About your ecoman account');
		$email->setMessage($data['message']);
		if($email->send())
		{
            return true;
		}
		else
		{
			echo 'error sending email. please report to celero.info@gmail.com';
			//exit();
            return false;
		}
	}

	// checks password matches
	public function password_check(){
		if($this->request->getPost('new_pass') == $this->request->getPost('new_pass_again')){
			return true;
		}
		else{
			$this->form_validation->set_message('password_check','Passwords aren\'t same.');
			return false;
		}
	}

	// generates 20 char random string for every user.
	public function generateRandomString() {
	    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
	    $randomString = '';
	    for ($i = 0; $i < 20; $i++) {
	        $randomString .= $characters[rand(0, strlen($characters) - 1)];
	    }
	    return $randomString;
	}

	// come on.
	public function user_logout(){
		$this->session->sess_destroy();
		return redirect()->to(site_url(''));
	}
}
?>
