+++
title = 'Randomness of Life'
date = 2023-03-20T10:02:19+01:00
type = 'Article'
tags = ['Genetic Algorithm', 'Rust']
images = []
series = 'Franklin'

show_table_of_contents = true

disqus_identifier = '106d479fccbf4664c64e7fe4d855b7d1'
## Optional, will use <title> tag value instead.
# disqus_title = ''
## Optional, will use window.location.href instead.
# disqus_url = ''
show_disqus = true
show_comment_count = true

share_buttons = ['facebook', 'twitter']

katex = false
draft = true
+++

In the previous article from this series (see [here]({{< relref "/articles/franklin/art-from-chaos" >}})), we've talked
about genetic algorithms and how they can be used to generate art. Now let's put those ideas into action and focus on
implementing the first part of our artistic toolset: **mutators**.

<!--more-->

## Preparing the ecosystem

Before we begin working on mutators, we need to prepare an environment in which our specimens can thrive. We don't need
much - right now the only thing we need is a generation. For the record, in this context, a generation is a collection
of specimen which can be mutated, scored, and bred (basically experimented upon) to get us closer to the optimum.
Since our specimens are images, they can be represented by the following structs:

```rust
struct Pixel {
    r: u8,
    g: u8,
    b: u8,
}

struct Image {
    height: usize,
    width: usize,
    pixels: Vec<Pixel>,
}
```

Representing each pixel as a 24-bit value gives us some flexibility here - it allows us to operate on two color depths:
[true color](https://en.wikipedia.org/wiki/Color_depth#True_color_(24-bit)) (which uses 24-bit colors) and
[grayscale](https://en.wikipedia.org/wiki/Grayscale) (8-bit). Creating a grayscale pixel can be done by setting up all
color channels to the same value. True, it uses thrice as much memory as it could, but...

> Premature optimization is the root of all evil.  
> ~ Donald Knuth

{{< underline >}}Method of initializing{{< /underline >}}[^1] the generation will affect how fast we can search the
solution space. As the algorithm produces more fitted images, the specimens get closed to the source image. But we don't
really care how fast the optimum can be achieved, frankly, we don't really care about achieving the optimum in the first
place. It is _the process_ of getting more fitted images and seeing how they evolve what's really interesting. Therefore
our generation will be initialized by blank images - images filled by white pixels. It will reduce pace of solution
space search, but will produce images that are more interesting visually. We are here to do art, after all. :art:

```rust
impl Pixel {
    #[must_use]
    pub const fn white() -> Self {
        Pixel::new(255, 255, 255)
    }

    #[must_use]
    pub const fn new(r: u8, g: u8, b: u8) -> Self {
        Pixel { r, g, b }
    }
}

impl Image {
    #[must_use]
    pub fn new(height: usize, width: usize, pixels: Vec<Pixel>) -> Self {
        Self {
            height,
            width,
            pixels,
        }
    }

    #[must_use]
    pub fn blank(height: usize, width: usize, pixel: &Pixel) -> Self {
        let size = height * width;
        let pixels = vec![pixel.clone(); size];

        Self::new(height, width, pixels)
    }
}

#[must_use]
fn get_first_generation(
    vec_len: usize,
    image_height: usize,
    image_width: usize
) -> Vec<Image> {
    let pixel = Pixel::white();
    vec![Image::blank(height, width, &pixel); vec_len]
}
```

This code takes care of initializing the generation. :ok_hand:

## Throwing dice and hoping for the best

As was mentioned in the previous article, mutators act only on one specimen at a time, inserting random modification on
it. With that description alone, we can already define a contract for all mutators we're going to implement:

```rust
pub trait Mutator {
    fn mutate(&self, image: &mut Image);
}
```

Why `&self` and not `&mut self`? Due to the fact that mutations are independent of one another, they can be performed
concurrently. In fact, as we will see in the future articles, mutating and scoring are the only steps that can be
_easily_ run in parallel.

{{< figure src="./genetic-algorithm-flow.png" alt="Genetic Algorithm Flow"
    caption="A diagram showing the flow of actions applied on a single generation."
>}}

### Throwing a rectangular dice

As rectangles are the easiest shape to draw (both in programming and IRL) let's start with those.

<!-- TODO: At the end link the current commit hash to lock it down. -->

<!-- Footnotes -->

[^1]: Usually the generation is generated randomly. See
[here](https://en.wikipedia.org/wiki/Genetic_algorithm#Initialization).
