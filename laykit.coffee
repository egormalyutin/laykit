do ->
	gen = ->
		indent = (i, code) ->
			return code
				.split "\n"
				.map (row) -> i + row
				.join "\n"

		sizes =
			esm: "max-width: 576px"
			sm:  "min-width: 576px"
			md:  "min-width: 768px"
			lg:  "min-width: 992px"
			xl:  "min-width: 1200px"

		rules = []
		add = (selectors, code) ->
			rules.push { selectors, code }

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

		#####################
		##### CONTAINER #####
		#####################

		add ["cont"], """
			display: flex;
			position: relative;
		"""

		################################
		##### COLUMN, ROW AND ABS ######
		################################

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
						display: inline-block;
						width: calc(""" + scale + """);
						margin-left: 0;
						margin-right: 0;
					"""

					add ["row-" + col], """
						display: inline-block;
						height: calc(""" + scale + """);
						margin-top: 0;
						margin-bottom: 0;
					"""

				add ["col-" + col + "-" + sz], """
					display: inline-block;
					width: calc(""" + scale + """);
					margin-left: 0;
					margin-right: 0;
				"""
				add ["row-" + col + "-" + sz], """
					display: inline-block;
					width: calc(""" + scale + """);
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

		################
		##### CODE #####
		################

		genPrefix = (prefix, { selectors, code }) ->
			sels = selectors
				.map (selector) -> "." + prefix + selector
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
			.map (rule) ->
				return genPrefix "", rule
			.join "\n"

		code += "\n"

		for size of sizes
			code += genSize size, rules
			code += "\n"

		return code

	#### GENERATE ####
	start = new Date
	code = gen()
	end = new Date() - start
	console.log "laykit deployed in " + end + "ms"

	#### ADD ####
	style = document.createElement "style"
	style.innerHTML = code
	style.type = "text/css"

	document.head.appendChild style

# todo: cancel
