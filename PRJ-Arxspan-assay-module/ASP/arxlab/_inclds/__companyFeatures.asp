<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<!-- #include virtual="/arxlab/_inclds/security/functions/fnc_setUpCfgData.asp"-->
<%
whichClient = getCompanySpecificSingleAppConfigSetting("clientName", session("companyId"))
'start default values.  Required for local install
canUseGod = False
canSeeShowUserReport = False
canDeleteStructureReg = False
canEditStructureReg = False
'end default values

'remove for local install
Select Case whichClient
	Case "ARXSPAN"
		If session("roleNumber") <= 1 Then
			canSeeShowUserReport = True
			canUseGod = True
		End If
	Case "BROAD"
		If session("email") = "support@arxspan.com" Then
			canUseGod = True
			canSeeShowUserReport = True
		End If
End select

set usersWhoAreAllowedToDeleteRegStructures = CreateObject("System.Collections.ArrayList")
usersWhoAreAllowedToDeleteRegStructures.add "support@arxspan.com"
usersWhoAreAllowedToDeleteRegStructures.add "shota.ikeda1@takeda.com"
usersWhoAreAllowedToDeleteRegStructures.add "nobuyuki.matsunaga1@takeda.com"
usersWhoAreAllowedToDeleteRegStructures.add "junya.shirai1@takeda.com"
usersWhoAreAllowedToDeleteRegStructures.add "yasufumi.miyamoto1@takeda.com"
usersWhoAreAllowedToDeleteRegStructures.add "amanda.lashua@arxspan.com"
usersWhoAreAllowedToDeleteRegStructures.add "karolina@broadinstitute.org"
usersWhoAreAllowedToDeleteRegStructures.add "lee.herman@sunovion.com"
usersWhoAreAllowedToDeleteRegStructures.add "noel.powell@sunovion.com"
usersWhoAreAllowedToDeleteRegStructures.add "dlahr@foghorntx.com"
usersWhoAreAllowedToDeleteRegStructures.add "chris.lowden@workflowinformatics.com"
usersWhoAreAllowedToDeleteRegStructures.add "rvaswani@foghorntx.com"
usersWhoAreAllowedToDeleteRegStructures.add "jmarchionna@foghorntx.com"
usersWhoAreAllowedToDeleteRegStructures.add "jyang@foghorntx.com"
usersWhoAreAllowedToDeleteRegStructures.add "saravanan.a@zifornd.com"
usersWhoAreAllowedToDeleteRegStructures.add "nishinos1@sc.sumitomo-chem.co.jp"
usersWhoAreAllowedToDeleteRegStructures.add "nishinos1@sc.sumitomo-chem.co.jp"
usersWhoAreAllowedToDeleteRegStructures.add "tenzin@broadinstitute.org"
usersWhoAreAllowedToDeleteRegStructures.add "kirsten.beaudry@crisprtx.com"
usersWhoAreAllowedToDeleteRegStructures.add "echamber@broadinstitute.org" 
usersWhoAreAllowedToDeleteRegStructures.add "wesley.dobbs@crisprtx.com"
usersWhoAreAllowedToDeleteRegStructures.add "coalmann@axialbiotherapeutics.com"
usersWhoAreAllowedToDeleteRegStructures.add "Kashif.Hoda@sagerx.com"
usersWhoAreAllowedToDeleteRegStructures.add "surekha.agarwal@sagerx.com"
usersWhoAreAllowedToDeleteRegStructures.add "prybczynski@amicusrx.com"
usersWhoAreAllowedToDeleteRegStructures.add "jhoran@nuvalent.com"
usersWhoAreAllowedToDeleteRegStructures.add "iwrona@yumanity.com"
usersWhoAreAllowedToDeleteRegStructures.add "mlucas@yumanity.com"
usersWhoAreAllowedToDeleteRegStructures.add "kozboya@yumanity.com"
usersWhoAreAllowedToDeleteRegStructures.add "mmacdonnell@yumanity.com"

If usersWhoAreAllowedToDeleteRegStructures.contains(session("email")) then
	canDeleteStructureReg = True
end if

set usersWhoAreAllowedToEditRegStructures = CreateObject("System.Collections.ArrayList")
usersWhoAreAllowedToEditRegStructures.add "support@arxspan.com"
usersWhoAreAllowedToEditRegStructures.add "shota.ikeda1@takeda.com"
usersWhoAreAllowedToEditRegStructures.add "nobuyuki.matsunaga1@takeda.com"
usersWhoAreAllowedToEditRegStructures.add "junya.shirai1@takeda.com"
usersWhoAreAllowedToEditRegStructures.add "yasufumi.miyamoto1@takeda.com"
usersWhoAreAllowedToEditRegStructures.add "amanda.lashua@arxspan.com"
usersWhoAreAllowedToEditRegStructures.add "karolina@broadinstitute.org"
usersWhoAreAllowedToEditRegStructures.add "lee.herman@sunovion.com"
usersWhoAreAllowedToEditRegStructures.add "noel.powell@sunovion.com"
usersWhoAreAllowedToEditRegStructures.add "dlahr@foghOrntx.com"
usersWhoAreAllowedToEditRegStructures.add "chris.lowden@wOrkflowinfOrmatics.com"
usersWhoAreAllowedToEditRegStructures.add "rvaswani@foghOrntx.com"
usersWhoAreAllowedToEditRegStructures.add "jyang@foghOrntx.com"
usersWhoAreAllowedToEditRegStructures.add "jmarchionna@foghOrntx.com"
usersWhoAreAllowedToEditRegStructures.add "saravanan.a@zifOrnd.com"
usersWhoAreAllowedToEditRegStructures.add "nishinos1@sc.sumitomo-chem.co.jp"
usersWhoAreAllowedToEditRegStructures.add "fbrucelle@foghOrntx.com"
usersWhoAreAllowedToEditRegStructures.add "nishinos1@sc.sumitomo-chem.co.jp"
usersWhoAreAllowedToEditRegStructures.add "twynn@accenttx.com"
usersWhoAreAllowedToEditRegStructures.add "Kashif.Hoda@sagerx.com"
usersWhoAreAllowedToEditRegStructures.add "daniel.hOrne@sagerx.com"
usersWhoAreAllowedToEditRegStructures.add "bingsong.han@sagerx.com"
usersWhoAreAllowedToEditRegStructures.add "scott.brown@sunovion.com"
usersWhoAreAllowedToEditRegStructures.add "dharvey@28-7tx.com"
usersWhoAreAllowedToEditRegStructures.add "prybczynski@amicusrx.com"
usersWhoAreAllowedToEditRegStructures.add "jhOran@nuvalent.com"
usersWhoAreAllowedToEditRegStructures.add "iwrona@yumanity.com"
usersWhoAreAllowedToEditRegStructures.add "mlucas@yumanity.com"
usersWhoAreAllowedToEditRegStructures.add "kozboya@yumanity.com"
usersWhoAreAllowedToEditRegStructures.add "coalmann@axialbiotherapeutics.com"
usersWhoAreAllowedToEditRegStructures.add "surekha.agarwal@sagerx.com"
usersWhoAreAllowedToEditRegStructures.add "mmacdonnell@yumanity.com"
usersWhoAreAllowedToEditRegStructures.add "vkuria@yumanity.com"
usersWhoAreAllowedToEditRegStructures.add "ckatz@bostonbiomedical.com"
usersWhoAreAllowedToEditRegStructures.add "kerry.spear@blueoakpharma.com"
usersWhoAreAllowedToEditRegStructures.add "jlowe@foghorntx.com"
usersWhoAreAllowedToEditRegStructures.add "jyang@foghorntx.com"
usersWhoAreAllowedToEditRegStructures.add "dhuang@foghorntx.com"
usersWhoAreAllowedToEditRegStructures.add "cdeng@foghorntx.com"
usersWhoAreAllowedToEditRegStructures.add "sschiller@foghorntx.com"
usersWhoAreAllowedToEditRegStructures.add "snegretti@foghorntx.com"
usersWhoAreAllowedToEditRegStructures.add "bvieira@dyne-tx.com"
usersWhoAreAllowedToEditRegStructures.add "bquinn@dyne-tx.com"
usersWhoAreAllowedToEditRegStructures.add "sspring@dyne-tx.com"
usersWhoAreAllowedToEditRegStructures.add "tweeden@dyne-tx.com"

If usersWhoAreAllowedToEditRegStructures.contains(session("email")) then
	canEditStructureReg = True
end if

'end remove for local install
%>