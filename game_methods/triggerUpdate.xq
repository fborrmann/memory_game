<!-- function that gets card ID and triggers an update method	 ->




declare function local:triggerUpdate ($c as element(card))     <!-- or $c as	xs:String ->
as xs:String   <!-- or as element(card) ->
{
	 return {local:updateStatus($c/id)}
}



declare function local:triggerUpdate ($c as element(card))
as xs:String   <!-- or as element(card) ->
{
return
  <card id = $c/id card_state="shown">
  </card>
}
