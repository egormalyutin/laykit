do ->
	gen = ->
		indent = (i, code) ->
			return code
				.split "\n"
				.map (row) -> i + row
				.join "\n"

		sizes =
			esm: "max-width: 576px"
			sm:  "min-width: 576px) and (max-width: 767px"
			md:  "min-width: 768px) and (max-width: 991px"
			lg:  "min-width: 992px) and (max-width: 1199px"
			xl:  "min-width: 1200px"

		rules = []
		add = (selectors, code) ->
			rules.push { selectors, code }

		#####################
		##### CONTAINER #####
		#####################

		add ["cont", "row"], """
			padding: 0;
			margin: 0;
			display: flex;
			flex-direction: row;
			flex-wrap: wrap;
			width: 100%;
			position: relative;
			box-sizing: border-box;
		"""

		add ["column"], """
			padding: 0;
			margin: 0;
			display: flex;
			flex-direction: column;
			flex-wrap: wrap;
			width: 100%;
			position: relative;
			box-sizing: border-box;
		"""

		################################
		##### COLUMN, ROW AND ABS ######
		################################

		# TODO: row width

		for col in [1..12]
			for sz in [1..col]
				if sz is 1
					scale = "100%/" + col
				else if sz is col
					scale = "100%"
				else
					scale = "100%/" + col + "*" + sz

				if sz is 1
					add ["col-" + col], """
						width: calc(""" + scale + """);
						align-self: start;
						margin-left: 0;
						margin-right: 0;
					"""

					add ["row-" + col], """
						height: calc(""" + scale + """);
						align-self: start;
						margin-top: 0;
						margin-bottom: 0;
					"""

				add ["col-" + col + "-" + sz], """
					width: calc(""" + scale + """);
					align-self: start;
					margin-left: 0;
					margin-right: 0;
				"""
				add ["row-" + col + "-" + sz], """
					width: calc(""" + scale + """);
					align-self: start;
					margin-top: 0;
					margin-bottom: 0;
				"""

		for col in [1..12]
			for sz in [1..col]
				pos = "100%/" + col + "*" + sz

				add ["offset-col-" + col + "-" + sz], """
					margin-left: calc(""" + pos + """);
				"""
				add ["offset-row-" + col + "-" + sz], """
					margin-top: calc(""" + pos + """);
				"""

		for num in [1..10]
			for tn in [0..9]
				add ["height-col-" + num + "-" + tn], """
					position: relative;
				"""

				add ["height-col-" + num + "-" + tn + ":before"], """
					content: '';
					display: block;
					padding-top: calc(100%*""" + (num + tn / 10) + """);
				"""

				add ["height-col-" + num + "-" + tn + " > *"], """
					position: absolute;
					top: 0;
					left: 0;
					right: 0;
					bottom: 0;
				"""

		#######################
		##### MIN AND MAX #####
		#######################

		#################
		##### ORDER #####
		#################

		maxOrd = 15

		for ord in [1..maxOrd]
			add ["order-" + ord], """
				order: """ + ord + """;
			"""

		add ["order-first"], """
			order: -1;
		"""

		add ["order-last"], """
			order: """ + (maxOrd + 1) + """;
		"""

		#################
		##### FLUID #####
		#################

		add ["fluid"], """
			flex: 1;
		"""

		#################
		##### ALIGN #####
		#################

		add ["align-self-start"], """
			align-self: start;
		"""

		add ["align-self-center"], """
			align-self: center;
		"""

		add ["align-self-end"], """
			align-self: end;
		"""

		add ["justify-content-start"], """
			justify-content: start;
		"""

		add ["justify-content-center"], """
			justify-content: center;
		"""

		add ["justify-content-end"], """
			justify-content: end;
		"""

		add ["justify-content-around"], """
			justify-content: space-around;
		"""

		add ["justify-content-between"], """
			justify-content: space-between;
		"""

		##################
		##### CENTER #####
		##################

		add ["cont-vertical-center", "cont-v-center", "cont-center"], """
			display: flex;
			flex-direction: row;
			align-items: center;
		"""

		add ["cont-horizontal-center", "cont-h-center", "cont-center"], """
			display: flex;
			flex-direction: row;
			justify-content: center;
		"""

		###################
		##### VISIBLE #####
		###################

		add ["invisible", "display-none"], """
			display: none;
		"""

		add ["display-block"], """
			display: block;
		"""

		add ["display-flex"], """
			display: flex;
		"""

		add ["display-inline-block"], """
			display: inline-block;
		"""

		add ["display-inline-flex"], """
			display: inline-flex;
		"""

		################
		##### CODE #####
		################

		allSelectors = []

		genPrefix = (prefix, { selectors, code }) ->
			sels = selectors
				.map (selector) -> 
					r = "." + prefix + selector 
					allSelectors.push r
					return r

				.join ", "

			return sels + " {\n" + indent("\t", code) + "\n}"

		genSize = (size, rules) ->
			inner = rules
				.map (rule) ->
					return genPrefix size + "-", rule
				.join "\n"

			inner = "@media (" + sizes[size] + ") {\n" + indent "\t", inner
			inner += "\n}"

			return inner

		code = rules
			.map (rule) -> genPrefix "", rule
			.join "\n"

		code += "\n"

		for size of sizes
			code += genSize size, rules
			code += "\n"

		#### BOX SIZING ####
		as = allSelectors.join(", ")
		code += "\n" + as + " {\nbox-sizing: border-box;\n}"

		return code

	start = new Date

	#### GENERATE ####
	code = gen()

	if window?
		style = document.createElement "style"
		style.innerHTML = code
		style.type = "text/css"
		document.head.appendChild style

		end = new Date() - start
		console.log "laykit deployed in " + end + "ms"

	else

		fs   = require "fs"
		path = require "path"
		fs.writeFileSync path.join(__dirname, "laykit.css"), code
		end = new Date() - start
		console.log "laykit compiled in " + end + "ms"

# todo: cancel
