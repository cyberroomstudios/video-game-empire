local MessageEnum = table.freeze({

	-- Usado na notificação quando o jogador não tem dinheiro pra comprar algo
	NO_HAVE_MONEY = "Not Enough Money",

	--------------------------------------
	-- #### Falas do NPC de Vendas #### --
	--------------------------------------

	-- Mensagem padrão do NPC
	NPC_SELL_DEFAULT = "Hello, my name is Roblox or Game Buyer",

	-- Usado para mostrar que a operação está sendo processada
	NPC_SELL_WAIT = "Please wait while I check this.",

	-- Usado quando não tem nada pra comprar do jogador
	NPC_SELL_NOTHING_TO_BUY = "You don't have any games to sell at the moment.",

	-- Usado pra mostrar o resultado da venda
	NPC_SELL_RESULT = "Cool! I bought %d of your games and paid you %d.",

	-- Usado pra dizer que não tem nada na mão do jogador
	NPC_SELL_NOTHING_IN_HAND = "You have nothing in your hand",

	-- Usado para mostrar quando o jogo vale
	NPC_SELL_GAME_VALUE = "Your game is worth %d",

	--------------------------------------
	-- ####          REBIRTH       #### --
	--------------------------------------
	NO_REQUIREMENTS = "You need all the requirements",

	SUCCESS_REBIRTH = "Rebirth obtained with Success",

	--------------------------------------
	-- ####          CODES       #### ----
	--------------------------------------
	CODE_APPLIED = "Code Applied and Award Obtained",

	CODE_ALREADY_USES = "You Have Already Used This Code",
	CODE_DOES_NOT_EXIST = "This Code does not exist",

	--------------------------------------
	-- ####       DAILY REWARD   #### ----
	--------------------------------------

	DAILY_REWARD_SUCCESS = "Congratulations. You won the daily prize!",

	--------------------------------------
	-- ####       MAP REWARD   #### ----
	--------------------------------------

	MAP_REWARD_SUCCESS = "Award Successfully Received!",
	MAP_REWARD_ERROR = "You Need To Fulfill All Items!",
	MAP_REWARD_ALREADY_OBTAINED = "You Have Already Obtained This Award!",

	--------------------------------------
	-- ####       INDEX          #### ----
	--------------------------------------

	INDEX_BASE_EMPTY = "This Base Is Empty!",
})

return MessageEnum
