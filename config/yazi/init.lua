local home = os.getenv("HOME")

require("omp"):setup({
    config = home .. "/.dotfiles/themes/oh-my-posh-yazi.json"
})
-- require("omp"):setup()

Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)
