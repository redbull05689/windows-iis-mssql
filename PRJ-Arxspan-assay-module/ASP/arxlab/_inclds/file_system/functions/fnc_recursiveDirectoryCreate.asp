<!-- #include virtual="/arxlab/ajax_checkers/isLoggedIn_securityCheck.asp"-->
<%
function recursiveDirectoryCreate(rootDir,dir)
	'create a whole path instead of the built in method that fails if the subdirectory doenst exist

	'get rid of trailing "\"
	If Right(rootDir,1) = "\" Then
		rootDir = Left(rootDir,Len(rootDir)-1) 
	End if

	'take the root directory out of the new path
	pathNoRoot = Replace(dir,rootDir,"")
	incPath = rootDir
	'split the directories to be created into chunks
	pathChunks = Split(pathNoRoot,"\")
	'loop through each folder to be created
	For iLocal = 0 To UBound(pathChunks)
		If pathChunks(iLocal) <> "" Then
			incPath = incPath & "\" & pathChunks(iLocal)
			dim fs
			set fs=Server.CreateObject("Scripting.FileSystemObject")
			'if the folder does not exist create it
			if fs.FolderExists(incPath)<>true then
				set f=fs.CreateFolder(incPath)
			end if
			
			set fs=nothing
		End if
	next

	'always return true
	recursiveDirectoryCreate = "success"
end function
%>