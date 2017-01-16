function init()

  --handler (listener) for messsages from the panel GUI sending this object the weapon to spawn
  message.setHandler("reinforce", function(_, _, params)
    reinforce(params)
  end)

end

function reinforce(weapon)
	if weapon then
		world.containerPutItemsAt(entity.id(), weapon, 0)
	end
end