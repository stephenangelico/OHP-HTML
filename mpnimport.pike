/*
Theory: Generate slides.html from MPN.

1) Read current status of MPN
2) Locate the "interesting bit"
3) Pull hymns from the git history
   git show `git log -S '<h3>R246 ' -1 --pretty=%H`^:slides.html
   sscanf(data, "%*s<h3>R246 %s</cite>", string hymn);
   If none, create stub (including empty citation and two verses)
4) Handle PP numberless:
   git show `git log -S '<h3>PP[0-9]* Title' --pickaxe-regex -1 --pretty=%H`^:slides.html
5) Update MPN if any PPs got their numbers added (require auth? or use pseudo-auth of 192.168?)
6) Handle title conflicts somehow

Interesting lines:
Hymn [PP] By Faith
-- see #4 and #5
Hymn [R540] Jesus, I Am Trusting, Trusting
-- see #3
Opening Prayer (BO)
-- nothing
Announcements (JA)
-- nothing
Bible reading: Matthew 11:1-19 (page 688) (LO)
-- emit <address> block
Offering [] (BO)
-- nothing
Prayer for our church and the world (JA)
-- nothing
Hymn [tune - R474] Put all your trust in God
-- probably disallow in favour of: Hymn [PP] Put all your trust in God (to R474)
-- parenthesized parts get dropped
Bible reading: Matthew 11:20-30 (page 689) (BO)
-- address as above
Sermon: “HELP FOR THE WEAK AND DOUBTING” (BO) 
-- ????? Stubs??? Something from sermon outline???
Hymn [R405] Not What I Am, O Lord, But What You Are
-- #3 above. Note the capitalization inconsistencies. Resolve?
Benediction (BO)
-- nothing
Exit []
-- nothing

*/
string current = Stdio.read_file("slides.html");
array(string) parts = ({ });
string sermonnotes = "";

string mpn_Welcome = #"<section data-bg=\"SolidDirt.png\">
<h3><img src=\"Cross.png\"> Ashburton Presbyterian Church</h3>
<p></p>
<h1>Welcome</h1>
<footer>Finding solid ground in Christ</footer>
</section>";
string mpn_Opening = ""; //Opening Prayer
string mpn_Prayer = "";
string mpn_Announcements = "";
string mpn_Offering = "";
string mpn_Benediction = "";
string mpn_Exit = "";

string mpn_Hymn(string line)
{
	sscanf(line, "Hymn [%s] %s", string id, string titlehint);
	//See if a hymn with that ID is in the current file. The git check
	//below won't correctly handle that case, so let's special-case it
	//for safety and simplicity.
	if (has_value(current, "<h3>" + id + ": "))
	{
		sscanf(current, "<h3>"+id+": %s</h3>%s</cite>", string title, string body);
		//TODO: Handle title/titlehint mismatches (not counting whitespace)
		if (!title || !body) error("Unable to parse current hymn: %O\n", line);
		return sprintf("<section>\n<h3>%s: %s</h3>%s</cite>\n</section>", id, title, body);
	}
	//Okay, it wasn't found. Locate the most recent commit that adds or removes
	//the string "<h3>HymnID: ". It'll be a removal, since that ID doesn't occur
	//in the current file.
	string sha1 = String.trim_all_whites(Process.run(({
		"git", "log", "-S", sprintf("<h3>%s: ", id), "-1", "--pretty=%H"
	}))->stdout);
	if (sha1 == "")
	{
		//No such hymn found. Create a stub.
		return sprintf(#"<section>
<h3>%s: %s</h3>

</section>
<section>

<cite>© 1900-2000 Someone, Somewhere</cite>
</section>", id, titlehint);
	}
	//Awesome! We have a SHA1 that *removed* this hymn ID.
	//Most likely, it removed the whole hymn text, but we don't care. All we
	//want is the text that was there *just before* the removal, which can be
	//referenced as 142857^ and the file name. (I love git!)
	string oldtext = Process.run(({"git", "show", sha1 + "^:slides.html"}))->stdout;
	//TODO: Dedup
	if (has_value(oldtext, "<h3>" + id + ": "))
	{
		sscanf(oldtext, "<h3>"+id+": %s</h3>%s</cite>", string title, string body);
		//TODO: Handle title/titlehint mismatches (not counting whitespace)
		if (!title || !body) error("Unable to parse hymn from %s: %O\n", sha1, line);
		return sprintf("<section>\n<h3>%s: %s</h3>%s</cite>\n</section>", id, title, body);
	}
	error("Hymn not found in %s: %O\n", sha1, line);
}

string mpn_Bible(string line)
{
	sscanf(line, "Bible reading: %s (page %d)", string ref, int page);
	if (!ref || !page) error("Unable to parse Scripture reading: %O\n", line);
	return sprintf("<section><address>%s\npage %d</address></section>", ref, page);
}

string mpn_Sermon(string line)
{
	sscanf(line, "Sermon: %s (", string title);
	return "<section>" + title + "</section>";
}

int main()
{
	//Some of the 'git log' commands could become majorly messed up if certain
	//types of edit have been made to slides.html since the last commit. So for
	//simplicity, just do a quick check against HEAD and die early.
	string HEAD = Process.run(({"git", "show", "HEAD:slides.html"}))->stdout;
	if (current != HEAD) exit(1, "For safety, it is forbidden to run this with uncommitted changes to slides.html.\n");

	string mpn = Protocols.HTTP.get_url_data("http://gideon.kepl.com.au:8000/mpn/sundaymusic.0");
	if (!mpn) exit(1, "Unable to retrieve MPN - are you offline?\n");
	sscanf(utf8_to_string(mpn), "%d\0%s", int mpnindex, mpn); //Trim off the indexing headers

	sscanf(current, "%s<section", string header);
	string footer = (current / "</section>")[-1];

	//Assume that MPN consists of several paragraphs, and pick the first one with a hymn.
	string service;
	foreach (mpn/"\n\n", string para)
		if (has_value(para, "\nHymn [")) service = para;
		else if (service && !sermonnotes) sermonnotes = para; //Not used for much
	if (!service) exit(1, "Unable to find Order of Service paragraph in MPN.\n");

	foreach (service/"\n", string line)
	{
		sscanf(line, "%[A-Za-z]", string word);
		string|function handler = this["mpn_" + word];
		if (!handler) exit(1, "ERROR: Unknown line %O\n", line);
		parts += ({stringp(handler) ? handler : handler(line)});
	}

	//If we get here, every line was recognized and accepted without error.
	Stdio.write_file("slides.html", string_to_utf8(header + (parts-({""}))*"\n" + footer));
	//No commit during testing.
	//Process.create_process(({"git", "commit", "slides.html", sprintf("-mUpdate slides from MPN #%d", mpnindex)}))->wait();
}
