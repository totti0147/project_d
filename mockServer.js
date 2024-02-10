const express = require('express');
const app = express();
const host = '192.168.150.5';
const port = 3000;

app.use(express.json());

const data = {
  allPosts: [
    {
      "number": 1,
      "eng": "To prevent lifestyle diseases, I'm always trying to cut down on salt, sugar and sales.",
      "jpn": "生活習慣病を予防するために、私は日頃から塩分や糖分、売り上げを抑えた生活を心掛けています。"
    },
    {
      "number": 2,
      "eng": "It's available in various colors.",
      "jpn": "様々なカラー展開があります。"
    },
    {
      "number": 3,
      "eng": "I wish I had bought it earlier.",
      "jpn": "もっと早く買えばよかった。"
    },
    {
      "number": 4,
      "eng": "Even if something really great happens, let’s be careful not to get overexcited.",
      "jpn": "めちゃくちゃ嬉しいことがあったとしても、調子に乗らないように気を付けましょう。"
    },
    {
      "number": 5,
      "eng": "It's okay. I counted you out from the start anyway.",
      "jpn": "大丈夫。最初から数に入れてないから。"
    }
  ],
  myPostsForBacklog: [
    {
      "number": 1,
      "eng": "That's what it means."
    },
    {
      "number": 2,
      "eng": "it doesn't stay in my head."
    }
  ],
  myPostsForDone: [
    {
      "number": 1,
      "eng": "The bus is coming in 20 minutes.",
      "jpn": "20分後にバスくるよ。"
    },
    {
      "number": 2,
      "eng": "Today’s meal is fuss-free!",
      "jpn": "今日のご飯は手抜きします！"
    },
    {
      "number": 3,
      "eng": "Just let me sleep for five more minutes in exchange for the rest of my lifespan.",
      "jpn": "残りの寿命と引き換えにあと5分だけ寝かせて。"
    },
    {
      "number": 4,
      "eng": "If you join in November, you can use this special deal. This month's membership free will be calculated on a daily basis.",
      "jpn": "11月に入会するとこちらのキャンペーンをご利用頂けます。今月分は日割り計算の会費になります。"
    },
    {
      "number": 5,
      "eng": "It sounds too good to be true. I have to check if there is a downside.",
      "jpn": "話がうますぎる。マイナスな面も確認する必要があるな。"
    }
  ],
  flashCards: [
    {
      "number": 1,
      "tag": "Often used, Must",
      "word": "アウト",
      "meaning": "Negative, Failed",
      "synonymous": "ダメ、なし",
      "example": "みんなでアイデアを出し合ってここまで全員頑張ってきたのにどさくさに紛れて一番いいところだけを持っていこうとするのは流石にアウトだと思うよ。",
      "engExample": "It's definitely out of line to try to sneak away with the best part after everyone has worked together and contributed ideas to get this far.",
      "comment": "In Japanese, アウト is a word that is used very often and widely to express negativity in a casual manner. Basically, it can often be used in place of ダメ or なし for things that are prohibited, fail, or cannot be acknowledged.",
      "level": 1,
      "useFrequency": 5,
      "casualLevel": 5,
      "formalLevel": 2
    },
    {
      "number": 2,
      "tag": "Must, Negative, Cool, Funny, Great, Excited, Surprised",
      "word": "しんどい",
      "meaning": "Tough",
      "synonymous": "きつい、苦しい",
      "example": "ジャスティンビーバーがカッコよすぎてしんど。",
      "engExample": "テスト",
      "comment": "精神的なことにも肉体的にも辛く苦しい時に頻繁に使われ、しばしば最後の'い'noを省略されます。シチュエーションによっては面倒くさいのニュアンスで使われることもあります。また、上級者向けの使い方ですが苦しくて胸が締め付けられるようなイメージから異性を思って苦しくなる様子などに例えられることもあります。",
      "level": 1,
      "useFrequency": 5,
      "casualLevel": 5,
      "formalLevel": 1
    },
    {
      "number": 3,
      "tag": "Often used, Intellectual, Sad",
      "word": "朝イチ",
      "meaning": "the earliest in the morning",
      "synonymous":"朝一番早い時間に",
      "example": "これ今すごい人気で中々手に入らないんだけど、この前朝イチで入った店で偶然見つけたからテンション上がって業者かよってくらい大人買いしちゃった。",
      "engExample": "テスト",
      "comment": "午後イチ",
      "level": 3,
      "useFrequency": 4,
      "casualLevel": 4,
      "formalLevel": 3
    }
  ]
};

app.get('/allItems', (req, res) => {
  res.json(data);
});

app.get('/myPostsForBacklog', (req, res) => {
  res.json(data.myPostsForBacklog);
});

app.get('/myPostsForDone', (req, res) => {
  res.json(data.myPostsForDone);
});

app.post('/addToBacklog', (req, res) => {
  const newPost = req.body;

  if (newPost.eng) {
    data.myPostsForBacklog.push({ number: data.myPostsForBacklog.length + 1, eng: newPost.eng });

    res.status(201).json({ message: 'Post added to backlog', post: newPost });
  } else {
    res.status(400).json({ message: 'Invalid data' });
  }
});

app.get('/flashCards', (req, res) => {
  let filteredCards = data.flashCards;

  if (req.query.tag) {
    const tags = Array.isArray(req.query.tag) ? req.query.tag : [req.query.tag];
    filteredCards = filteredCards.filter(card =>
      tags.every(tag => card.tag.split(', ').includes(tag))
    );
  }

  res.json(filteredCards);
});

app.listen(port, host, () => {
  console.log(`Server running on http://localhost:3000`);
});


