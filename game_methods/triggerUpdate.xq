<!-- function that gets card ID and triggers an update method	 ->
<!-- needs to be tested	 ->



<!-- this version triggers seperate update function	 ->
declare function local:triggerUpdate ($c as element(card))
as element(card)
{
	 return {local:updateStatus($c/id)}
}


<!-- this version does the update itself (dummy update) ->
declare function local:triggerUpdate ($c as element(card))
as element(card)
{
return
  <card id = $c/id card_state="shown">
  </card>
}
