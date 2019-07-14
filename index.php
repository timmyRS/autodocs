<?php
$event = @$_SERVER["HTTP_X_GITHUB_EVENT"];
$body = file_get_contents("php://input");
$data = json_decode($body, true);
if($event != "push" || substr($data["ref"], 0, 11) != "refs/heads/")
{
	exit;
}
$git = 'GIT_SSH="'.__DIR__.'/ssh" git';
$repo = $data["repository"]["full_name"];
if(is_dir("repos/$repo"))
{
	chdir("repos/$repo");
	shell_exec("$git pull");
}
else
{
	shell_exec("$git clone ".escapeshellarg("git@github.com:$repo")." ".escapeshellarg("repos/$repo"));
	chdir("repos/$repo");
	shell_exec("$git config user.name \"autodocs by timmyrs\"");
	shell_exec("$git config user.email void@timmyrs.de");
}
shell_exec("$git checkout ".escapeshellarg(substr($data["ref"], 11)));
if(file_exists(".doxygen"))
{
	echo "doxygen .doxygen\n";
	shell_exec("doxygen .doxygen");
	if(trim(shell_exec("$git status | tail -n 1")) != "nothing to commit, working tree clean")
	{
		shell_exec("$git add . && $git commit -a -m \"Update docs\" --no-verify && $git push");
	}
}
