# Klepsidra

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## To do

- Make form dynamic: changing start or end times must recalculate durations
- Enable changing duration unit, automatically recalculating durations
- Explore defining custom durations and recalculating durations in terms of new time blocks
- Resize datetime, duration and duration unit controls to more efficiently use space
- Change tag to a many-to-many relationship
- Update tag picking for multiple tag selection 
- Start implementing colour palette 
- Reformat listing display to a more useful format, removing description field to a popup box or tooltip; change date display to more informative format
- Change data defaults for duration to nil, and no duration time units until clocking out

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
