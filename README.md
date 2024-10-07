# SWGOH Comlink RubyGem

## Description

This Gem is a wrapper for SWGOH Comlink servers. For more information on that, [visit their Github page](https://github.com/swgoh-utils/swgoh-comlink).

## Installation

`gem install swgoh_comlink`

## Initialization

Start by initializing the base class which you can then use to call any endpoint available.

`comlink = SwgohComlink.new('mycomlinkserver.com')`

If HMAC signing is enabled, you can pass in your keys like this:

`comlink = SwgohComlink.new('mycomlinkserver.com', {secret_key: 'mysecretkey, access_key: 'myaccesskey'})`

## Usage

See the documentation [on the Wiki here](https://github.com/zmoses/SwgohComlink/wiki/Documentation).