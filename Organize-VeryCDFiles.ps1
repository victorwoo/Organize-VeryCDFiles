function Organize-Ed2kFiles {
param (
    $url = 'http://www.verycd.com/topics/2900036/'
)
    $response = Invoke-WebRequest $url -SessionVariable $rb
   
    $response.ParsedHtml.all | where {
        $class = $_.getAttributeNode('class')
        specified -eq $True -and value -eq 'blog_entry'
        #$_
    }


    $response.AllElements |
        Where Class -eq "blog_entry" |
        Select -First 1 | gm
#-ExpandProperty innerText


    $response.ParsedHtml.all | where {
        $_.class -eq 'blog_entry'
    } | %{
        echo $_
    }
    $response.AllElements | where class -eq 'blog_entry' | % {
        $_.getElementByTagName('table')
    }
    echo $response
}

Organize-Ed2kFiles