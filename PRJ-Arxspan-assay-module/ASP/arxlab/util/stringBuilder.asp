<%
' String concatenation is very expensive in Classic ASP.
' This class can be used to avoid large string concatenation.
Class StringBuilder
    Private arr         'the array of strings to concatenate
    Private growthRate  'the rate at which the array grows
    Private itemCount   'the number of items in the array

    Private Sub Class_Initialize()
        growthRate = 50
        itemCount = 0
        ReDim arr(growthRate)
    End Sub

    'Append a new string to the end of the array. If the number of items in the array is larger than the actual capacity of the array, then "grow" the array by ReDimming it.
    Public Sub Append(ByVal strValue)
        strValue=strValue & ""  'code borrowed from FastString to prevent crash on NULL'
        If itemCount > UBound(arr) Then
            ReDim Preserve arr(UBound(arr) + growthRate)
        End If

        arr(itemCount) = strValue
        itemCount = itemCount + 1
    End Sub

    ' Clear the content
    Public Sub Reset()
        Erase arr
        Class_Initialize
    End Sub

    'Concatenate the strings by simply joining your array of strings and adding no separator between elements.
    Public Function ToString()
        ToString = Join(arr, "")
    End Function
End Class
%>