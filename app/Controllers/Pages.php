<?php

namespace App\Controllers;

class Pages extends BaseController {

public function view($page)
{
	if ( ! file_exists('application/views/pages/'.$page.'.php'))
		{
			// Whoops, we don't have a page for that!
			show_404();
		}

		$data['title'] = ucfirst($page); // Capitalize the first letter

		//header için başkba bir fonksyion yaz buraya
		$this->load->view('pages/'.$page, $data);
	}
}