<?php echo view('template/header'); ?>
<div class="container">
    <div class="col-md-10 well">
        <h>
            <b>
                User Manual Download
            </b>
        </h>
        <br>
        <br> <!-- file name for the user manual is case sensitive on the server! -->
        <a href="<?php echo base_url('assets/28_8_20_Celero_User_Manual_prnt.pdf'); ?>">
            <div style="background-color:#2D8B42; color:white; text-align: center;">
                <?php echo lang("Validation.usermanual"); ?>
                <span class="glyphicon glyphicon-book">
                </span>
            </div>
        </a>
    </div>
    <br>
        <br>
            <br>
                <br>
                    <br>
                    <br>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/TndTasntKjk" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/0F7TKdyX_6I" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/EXQXdQ5Lb1A" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/XNK3CwElNQg" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <div class="col-md-10">
                            <iframe width="750" height="320" src="https://www.youtube.com/embed/TT217255jlY" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                        </div>
                        <br>
                        <br>
                        <br>
                        <br>
                        <!-- English FAQ -->
                        <div class="col-md-10">
                            <div class="swissheader">
                                <?php echo lang("Validation.faq"); ?>
                            </div>
                            <div class="helpheader">
                                What is difference between a user and a consultant? 
                            </div>
                            <div class="helpbody">
                                User are the most basic accounts, they can create companies and projects. Consultants are more advanced users which can view company profiles. If consultants are invited into a project they can do IS and CP analysis for this project.
                            </div>
                          
                            <div class="helpheader">
                                How to register as a consultant
                            </div>
                            <div class="helpbody">
                                First access to the profile page. If the user wants to change his status to “consultant” for an existing profile, he can access the profile page by logging in. Once the profile page displays, the user clicks on the “become a consultant” button, located in the left upper corner of the page.
                            </div>
                            <div class="helpheader">
                                How does the IS service find matching flows?
                            </div>
                            <div class="helpbody">
                                For now the IS service matches flows only by "flow name" and Input / Output flow type.
                            </div>
                           
                            <div class="helpheader">
                                What is the difference between a automated and a manual IS potential identification?
                            </div>
                            <div class="helpbody">
                                When the user clicks on the “IS-Potential Identification” button, a scroll down menu appears. The user can choose to: <br>
-  Operate a automatic IS detection (“Automated IS” button). When operating an Automated IS detection, CELERO automatically detects Potential IS by matching the flows that have the same name. The user then selects from the pool of Potential IS the ones that seem the most relevant.<br>
-   Operate a manual IS detection (“Manual IS” button). When operating a Manual IS detection, CELERO displays all available flows from the opened project and the user himself matches the flow that can be mutualized.
                            </div>
	                     </div>
                    </br>
                </br>
            </br>
        </br>
    </br>
</div>
<?php echo view('template/footer'); ?>
