function nodeToString(node)
{
	//input element get back HTML string
	el = document.createElement("div")
	el.appendChild(node.cloneNode(true))
	return el.innerHTML
}