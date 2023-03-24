+++
title = 'Randomness of Life'
date = 2023-03-20T10:02:19+01:00
type = 'Article'
tags = ['Genetic Algorithm', 'Rust']
images = ['alexander-grey-2eAkk5lIkC8-unsplash.jpg']
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

katex = true
draft = true
+++

In the previous article from this series (see [here]({{< relref "/articles/franklin/art-from-chaos" >}})), we've talked
about genetic algorithms and how they can be used to generate art. Now let's put those ideas into action and focus on
implementing the first part of our artistic toolset: **mutators**.

<!--more-->

## Preparing the ecosystem

Before we begin working on mutators, we need to prepare an environment in which our specimens can thrive. We don't need
much - right now the only thing is _a generation_. For the record, in this context, a generation is a collection of
specimen which can be mutated, scored, and bred (basically experimented upon) to get us closer to the optimum. Since our
specimens are images, they can be represented by the following structs:

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
really care about how _fast_ the optimum can be achieved, frankly, we don't really care about achieving the optimum in
the first place. It is _the process_ of getting more fitted images and seeing how they evolve what's really interesting.
Therefore our generation will be initialized by blank images - images filled by white pixels. It will reduce pace of
solution space search, but will produce images that are more visually interesting. We are here to do art, after all.
:art:

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

As was mentioned in the previous article, mutators act only on one specimen at a time, inserting random modification
onto it. With that description alone, we can already define a contract for all mutators we're going to implement:

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

Rectangles are the easiest shape to draw both algorithmically and IRL; our first mutator will use rectangles as a
mutation primitive. To generate a random rectangle we need have the following:

* coordinates of one of its corners,
* width,
* height,
* fill color.

_Fill color_ is pretty straightforward, but other values have some constraints they need to meet. An image we'll be
mutating has width and height - let's assume it's {{< mono >}}n{{< /mono >}} and {{< mono >}}m{{< /mono >}}
respectively. Coordinates of one of the corners, in our case it's going to be top-left, are limited by the image
dimensions. Width and height are limited by both image dimensions, and the coordinates we just generated.

$$
    x \in \lbrack 0 .. n \lbrack \newline
    y \in \lbrack 0 .. m \lbrack \newline
    width \in \lbrack 1 .. n - x + 1 \lbrack \newline
    height \in \lbrack 1 .. m - y + 1 \lbrack \newline
$$

Why coordinates intervals are right-open? Because if the mutator selects the very right or bottom edge, then the
rectangle would need to have zero width/height. By not right-closing the intervals, we ensure that there's at least one
pixel which can be mutated :ok_hand:. Similarly both {{< mono >}}width{{< /mono >}} and {{< mono >}}height{{< /mono >}}
intervals are right-open to ensure that the rectangle will not overflow the image.

```rust
struct RandomRectangle {
    x: usize,
    y: usize,
    width: usize,
    height: usize,
}

#[must_use]
fn get_random_rectangle(random: &mut Random, image: &Image) -> RandomRectangle {
    let image_width = image.width();
    let image_height = image.height();

    let x = random.get_random(0usize, image_width);
    let y = random.get_random(0usize, image_height);

    let width = random.get_random(0usize, image_width - x) + 1;
    let height = random.get_random(0usize, image_height - y) + 1;

    RandomRectangle {
        x,
        y,
        width,
        height,
    }
}
```

Function `get_random_rectangle` is a neat helper: based on the given {{< underline >}}RNG{{< /underline >}}[^2] and
image, it returns a struct representing a random rectangle within the boundaries of the image.

Only two things left to do: generate random color and draw the shape. The implementation of rectangle mutator will look
like this:

```rust
#[derive(Debug, Default)]
pub struct RectangleMutator;

impl Mutator for RectangleMutator {
    fn mutate(&self, image: &mut Image) {
        let mut random = Random::default();
        let rect = self.get_random_rectangle(&mut random, image);

        let r = random.get_random(0u8, 255);
        let g = random.get_random(0u8, 255);
        let b = random.get_random(0u8, 255);

        let image_width = image.width();

        for i in rect.x..(rect.width + rect.x) {
            for j in rect.y..(rect.height + rect.y) {
                let pixel = &mut image[j * image_width + i];
                pixel.r(r);
                pixel.g(g);
                pixel.b(b);
            }
        }
    }
}
```

Cool, let's see what the program generates after 10 000 generations when initialized with
[Mona Lisa](https://en.wikipedia.org/wiki/File:Mona_Lisa,_by_Leonardo_da_Vinci,_from_C2RMF_retouched.jpg).

{{< figure src="./output_010000.png" alt="Random noise"
    title="Mona Lisa (generation #10 000)"
    class="border"
>}}

Doesn't really looks like anything. :neutral_face:  
Which isn't very surprising; the code did what it was suppose to do: it generated random rectangles on the white image.
Since we don't have any scoring logic yet (that's a topic for another article) the resulting image is composed of random
noise. We'll need to wait a bit longer to get an image that even remotely reflects "Mona Lisa".

### Throwing dice of other shapes

It'd be nice to have mutators other than `RectangleMutator`, which are able to mutate images with different shapes, but
I'm not going to cover them here. The reason is simple - they operate under the same rules: you need to define
boundaries first and then you need to draw the desired shape. I've implemented two other mutators: `TriangleMutator` and
`CircleMutator`. Their sources can be found
[here](https://github.com/nathiss/franklin/tree/73aa8dada3e8c3cae9aff5e24637785268e3527a/src/mutators).

## Afterword

You might've noticed that the code examples of this article are not strictly bounded together, meaning you cannot just
copy them to have a working example. A bunch of things like: `Random` implementation, loading the original image,
mutation loop, and the whole `impl Image` block are missing. If you want to have a working solution it's
[here](https://github.com/nathiss/franklin/tree/73aa8dada3e8c3cae9aff5e24637785268e3527a) _(locked down to the newest
commit at the moment of writing - 73aa8da)_. The goal of this series is not to go through every single line of code to
build a working utility, but rather to present an idea. So, moving forward all future articles from this series will
also be done in that style.

{{< figure src="./alexander-grey-2eAkk5lIkC8-unsplash.jpg" alt="Randomness of Life"
    caption="Photo by [Alexander Grey](https://unsplash.com/@sharonmccutcheon?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText) on [Unsplash](ttps://unsplash.com/photos/2eAkk5lIkC8?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText)"
    class="border"
>}}

Stay tuned :ocean:

<!-- Footnotes -->

[^1]: Usually the generation is generated randomly. See
[here](https://en.wikipedia.org/wiki/Genetic_algorithm#Initialization).

[^2]: `Random` is a project-private utility class. Source can be found
[here](https://github.com/nathiss/franklin/blob/73aa8dada3e8c3cae9aff5e24637785268e3527a/src/util/random.rs).
