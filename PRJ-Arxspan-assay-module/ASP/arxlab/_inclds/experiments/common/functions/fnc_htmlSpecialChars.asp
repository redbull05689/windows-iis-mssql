   <% ' Convert special characters to HTML entities.
    function htmlspecialchars(someString)
        ' Critical that ampersand is converted first, since all entities contain them.
        htmlspecialchars = replace(replace(replace(replace(someString, "&", "&amp;"), ">", "&gt;"), "<", "&lt;"), """", "&quot;")
    end function
 
    ' Convert HTML entities to special characters.
    function htmlspecialchars_decode(someString)
        htmlspecialchars_decode = replace(replace(replace(replace(someString, "&amp;", "&"), "&gt;", ">"), "&lt;", "<"), "&quot;", """")
    end function
    %>