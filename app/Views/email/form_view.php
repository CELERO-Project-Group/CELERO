<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>Codeigniter 4 Send Email </title>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
  <style>
    .container {
      max-width: 550px;
    }
  </style>
</head>
<body>
  <div class="container mt-5">
    <form method="post" action="sendMail">
      <div class="form-group">
        <label>Receiver Email</label>
        <input type="text" name="mailTo" class="form-control">
      </div>
       
      <div class="form-group">
        <label>Your Subject</label>
        <input type="text" name="subject" class="form-control">
      </div>
      <div class="form-group">
        <label>Message</label>
        <textarea rows="6" type="text" name="message" class="form-control"></textarea>
      </div>
      <div class="form-group">
        <button type="submit" class="btn btn-primary btn-block">Submit</button>
      </div>
    </form>
  </div>
</body>
</html>