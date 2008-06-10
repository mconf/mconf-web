function change_blog()
{
	miloc = "/spaces/1/blogs/" + document.form.blogs_spaces.value;	
	document.location.href = miloc;
}
function change_space()
{
	miloc = "/spaces/" + document.form.space_space.value;	
	document.location.href = miloc;
}