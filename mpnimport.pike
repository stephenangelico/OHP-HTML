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
Welcome / Call to worship () (BO)
-- emit opening slide
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

int main()
{
	//Some of the 'git log' commands could become majorly messed up if certain
	//types of edit have been made to slides.html since the last commit. So for
	//simplicity, just do a quick check against HEAD and die early.
	string HEAD = Process.run(({"git", "show", "HEAD:slides.html"}))->stdout;
	if (current != HEAD) exit(1, "For safety, it is forbidden to run this with uncommitted changes to slides.html.\n");
}
