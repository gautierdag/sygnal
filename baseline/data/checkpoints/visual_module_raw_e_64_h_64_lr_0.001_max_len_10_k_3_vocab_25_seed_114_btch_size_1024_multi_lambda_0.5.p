��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq cmodels.shapes_cnn
ShapesCNN
qX?   /home/lgpu0444/diagnostics-shapes/baseline/models/shapes_cnn.pyqX{  class ShapesCNN(nn.Module):
    def __init__(self, n_out_features):
        super().__init__()

        n_filters = 20

        self.conv_net = nn.Sequential(
            nn.Conv2d(3, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU()
        )
        self.lin = nn.Sequential(nn.Linear(80, n_out_features), nn.ReLU())

        self._init_params()

    def _init_params(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        batch_size = x.size(0)
        output = self.conv_net(x)
        output = output.view(batch_size, -1)
        output = self.lin(output)
        return output
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _state_dict_hooksqh)RqX   _load_state_dict_pre_hooksqh)RqX   _modulesqh)Rq(X   conv_netq(h ctorch.nn.modules.container
Sequential
qXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/container.pyqX�	  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    def __len__(self):
        return len(self._modules)

    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    def forward(self, input):
        for module in self._modules.values():
            input = module(input)
        return input
qtqQ)�q }q!(hh	h
h)Rq"hh)Rq#hh)Rq$hh)Rq%hh)Rq&hh)Rq'hh)Rq(hh)Rq)(X   0q*(h ctorch.nn.modules.conv
Conv2d
q+XJ   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/conv.pyq,X!  class Conv2d(_ConvNd):
    r"""Applies a 2D convolution over an input signal composed of several input
    planes.

    In the simplest case, the output value of the layer with input size
    :math:`(N, C_{\text{in}}, H, W)` and output :math:`(N, C_{\text{out}}, H_{\text{out}}, W_{\text{out}})`
    can be precisely described as:

    .. math::
        \text{out}(N_i, C_{\text{out}_j}) = \text{bias}(C_{\text{out}_j}) +
        \sum_{k = 0}^{C_{\text{in}} - 1} \text{weight}(C_{\text{out}_j}, k) \star \text{input}(N_i, k)


    where :math:`\star` is the valid 2D `cross-correlation`_ operator,
    :math:`N` is a batch size, :math:`C` denotes a number of channels,
    :math:`H` is a height of input planes in pixels, and :math:`W` is
    width in pixels.

    * :attr:`stride` controls the stride for the cross-correlation, a single
      number or a tuple.

    * :attr:`padding` controls the amount of implicit zero-paddings on both
      sides for :attr:`padding` number of points for each dimension.

    * :attr:`dilation` controls the spacing between the kernel points; also
      known as the à trous algorithm. It is harder to describe, but this `link`_
      has a nice visualization of what :attr:`dilation` does.

    * :attr:`groups` controls the connections between inputs and outputs.
      :attr:`in_channels` and :attr:`out_channels` must both be divisible by
      :attr:`groups`. For example,

        * At groups=1, all inputs are convolved to all outputs.
        * At groups=2, the operation becomes equivalent to having two conv
          layers side by side, each seeing half the input channels,
          and producing half the output channels, and both subsequently
          concatenated.
        * At groups= :attr:`in_channels`, each input channel is convolved with
          its own set of filters, of size:
          :math:`\left\lfloor\frac{C_\text{out}}{C_\text{in}}\right\rfloor`.

    The parameters :attr:`kernel_size`, :attr:`stride`, :attr:`padding`, :attr:`dilation` can either be:

        - a single ``int`` -- in which case the same value is used for the height and width dimension
        - a ``tuple`` of two ints -- in which case, the first `int` is used for the height dimension,
          and the second `int` for the width dimension

    .. note::

         Depending of the size of your kernel, several (of the last)
         columns of the input might be lost, because it is a valid `cross-correlation`_,
         and not a full `cross-correlation`_.
         It is up to the user to add proper padding.

    .. note::

        When `groups == in_channels` and `out_channels == K * in_channels`,
        where `K` is a positive integer, this operation is also termed in
        literature as depthwise convolution.

        In other words, for an input of size :math:`(N, C_{in}, H_{in}, W_{in})`,
        a depthwise convolution with a depthwise multiplier `K`, can be constructed by arguments
        :math:`(in\_channels=C_{in}, out\_channels=C_{in} \times K, ..., groups=C_{in})`.

    .. include:: cudnn_deterministic.rst

    Args:
        in_channels (int): Number of channels in the input image
        out_channels (int): Number of channels produced by the convolution
        kernel_size (int or tuple): Size of the convolving kernel
        stride (int or tuple, optional): Stride of the convolution. Default: 1
        padding (int or tuple, optional): Zero-padding added to both sides of the input. Default: 0
        dilation (int or tuple, optional): Spacing between kernel elements. Default: 1
        groups (int, optional): Number of blocked connections from input channels to output channels. Default: 1
        bias (bool, optional): If ``True``, adds a learnable bias to the output. Default: ``True``

    Shape:
        - Input: :math:`(N, C_{in}, H_{in}, W_{in})`
        - Output: :math:`(N, C_{out}, H_{out}, W_{out})` where

          .. math::
              H_{out} = \left\lfloor\frac{H_{in}  + 2 \times \text{padding}[0] - \text{dilation}[0]
                        \times (\text{kernel\_size}[0] - 1) - 1}{\text{stride}[0]} + 1\right\rfloor

          .. math::
              W_{out} = \left\lfloor\frac{W_{in}  + 2 \times \text{padding}[1] - \text{dilation}[1]
                        \times (\text{kernel\_size}[1] - 1) - 1}{\text{stride}[1]} + 1\right\rfloor

    Attributes:
        weight (Tensor): the learnable weights of the module of shape
                         (out_channels, in_channels, kernel_size[0], kernel_size[1]).
                         The values of these weights are sampled from
                         :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`
        bias (Tensor):   the learnable bias of the module of shape (out_channels). If :attr:`bias` is ``True``,
                         then the values of these weights are
                         sampled from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`

    Examples::

        >>> # With square kernels and equal stride
        >>> m = nn.Conv2d(16, 33, 3, stride=2)
        >>> # non-square kernels and unequal stride and with padding
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2))
        >>> # non-square kernels and unequal stride and with padding and dilation
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2), dilation=(3, 1))
        >>> input = torch.randn(20, 16, 50, 100)
        >>> output = m(input)

    .. _cross-correlation:
        https://en.wikipedia.org/wiki/Cross-correlation

    .. _link:
        https://github.com/vdumoulin/conv_arithmetic/blob/master/README.md
    """
    def __init__(self, in_channels, out_channels, kernel_size, stride=1,
                 padding=0, dilation=1, groups=1, bias=True):
        kernel_size = _pair(kernel_size)
        stride = _pair(stride)
        padding = _pair(padding)
        dilation = _pair(dilation)
        super(Conv2d, self).__init__(
            in_channels, out_channels, kernel_size, stride, padding, dilation,
            False, _pair(0), groups, bias)

    @weak_script_method
    def forward(self, input):
        return F.conv2d(input, self.weight, self.bias, self.stride,
                        self.padding, self.dilation, self.groups)
q-tq.Q)�q/}q0(hh	h
h)Rq1(X   weightq2ctorch._utils
_rebuild_parameter
q3ctorch._utils
_rebuild_tensor_v2
q4((X   storageq5ctorch
FloatStorage
q6X   59810416q7X   cuda:0q8MNtq9QK (KKKKtq:(KK	KKtq;�h)Rq<tq=Rq>�h)Rq?�q@RqAX   biasqBh3h4((h5h6X   59223328qCX   cuda:0qDKNtqEQK K�qFK�qG�h)RqHtqIRqJ�h)RqK�qLRqMuhh)RqNhh)RqOhh)RqPhh)RqQhh)RqRhh)RqShh)RqTX   trainingqU�X   in_channelsqVKX   out_channelsqWKX   kernel_sizeqXKK�qYX   strideqZKK�q[X   paddingq\K K �q]X   dilationq^KK�q_X
   transposedq`�X   output_paddingqaK K �qbX   groupsqcKubX   1qd(h ctorch.nn.modules.batchnorm
BatchNorm2d
qeXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/batchnorm.pyqfX#  class BatchNorm2d(_BatchNorm):
    r"""Applies Batch Normalization over a 4D input (a mini-batch of 2D inputs
    with additional channel dimension) as described in the paper
    `Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`_ .

    .. math::

        y = \frac{x - \mathrm{E}[x]}{ \sqrt{\mathrm{Var}[x] + \epsilon}} * \gamma + \beta

    The mean and standard-deviation are calculated per-dimension over
    the mini-batches and :math:`\gamma` and :math:`\beta` are learnable parameter vectors
    of size `C` (where `C` is the input size). By default, the elements of :math:`\gamma` are sampled
    from :math:`\mathcal{U}(0, 1)` and the elements of :math:`\beta` are set to 0.

    Also by default, during training this layer keeps running estimates of its
    computed mean and variance, which are then used for normalization during
    evaluation. The running estimates are kept with a default :attr:`momentum`
    of 0.1.

    If :attr:`track_running_stats` is set to ``False``, this layer then does not
    keep running estimates, and batch statistics are instead used during
    evaluation time as well.

    .. note::
        This :attr:`momentum` argument is different from one used in optimizer
        classes and the conventional notion of momentum. Mathematically, the
        update rule for running statistics here is
        :math:`\hat{x}_\text{new} = (1 - \text{momentum}) \times \hat{x} + \text{momemtum} \times x_t`,
        where :math:`\hat{x}` is the estimated statistic and :math:`x_t` is the
        new observed value.

    Because the Batch Normalization is done over the `C` dimension, computing statistics
    on `(N, H, W)` slices, it's common terminology to call this Spatial Batch Normalization.

    Args:
        num_features: :math:`C` from an expected input of size
            :math:`(N, C, H, W)`
        eps: a value added to the denominator for numerical stability.
            Default: 1e-5
        momentum: the value used for the running_mean and running_var
            computation. Can be set to ``None`` for cumulative moving average
            (i.e. simple average). Default: 0.1
        affine: a boolean value that when set to ``True``, this module has
            learnable affine parameters. Default: ``True``
        track_running_stats: a boolean value that when set to ``True``, this
            module tracks the running mean and variance, and when set to ``False``,
            this module does not track such statistics and always uses batch
            statistics in both training and eval modes. Default: ``True``

    Shape:
        - Input: :math:`(N, C, H, W)`
        - Output: :math:`(N, C, H, W)` (same shape as input)

    Examples::

        >>> # With Learnable Parameters
        >>> m = nn.BatchNorm2d(100)
        >>> # Without Learnable Parameters
        >>> m = nn.BatchNorm2d(100, affine=False)
        >>> input = torch.randn(20, 100, 35, 45)
        >>> output = m(input)

    .. _`Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`:
        https://arxiv.org/abs/1502.03167
    """

    @weak_script_method
    def _check_input_dim(self, input):
        if input.dim() != 4:
            raise ValueError('expected 4D input (got {}D input)'
                             .format(input.dim()))
qgtqhQ)�qi}qj(hh	h
h)Rqk(h2h3h4((h5h6X   59009984qlX   cuda:0qmKNtqnQK K�qoK�qp�h)RqqtqrRqs�h)Rqt�quRqvhBh3h4((h5h6X   60784576qwX   cuda:0qxKNtqyQK K�qzK�q{�h)Rq|tq}Rq~�h)Rq�q�Rq�uhh)Rq�(X   running_meanq�h4((h5h6X   59010080q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   running_varq�h4((h5h6X   59554016q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   num_batches_trackedq�h4((h5ctorch
LongStorage
q�X   59561200q�X   cuda:0q�KNtq�QK ))�h)Rq�tq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X   num_featuresq�KX   epsq�G>�����h�X   momentumq�G?�������X   affineq��X   track_running_statsq��ubX   2q�(h ctorch.nn.modules.activation
ReLU
q�XP   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/activation.pyq�X�  class ReLU(Threshold):
    r"""Applies the rectified linear unit function element-wise
    :math:`\text{ReLU}(x)= \max(0, x)`

    .. image:: scripts/activation_images/ReLU.png

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)
    """

    def __init__(self, inplace=False):
        super(ReLU, self).__init__(0., 0., inplace)

    def extra_repr(self):
        inplace_str = 'inplace' if self.inplace else ''
        return inplace_str
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X	   thresholdq�G        X   valueq�G        X   inplaceq��ubX   3q�h+)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   59258224q�X   cuda:0q�MNtq�QK (KKKKtq�(K�K	KKtqh)Rq�tq�Rqňh)RqƇq�Rq�hBh3h4((h5h6X   59144848q�X   cuda:0q�KNtq�QK K�q�K�q͉h)Rq�tq�RqЈh)Rqчq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�hVKhWKhXKK�q�hZKK�q�h\K K �q�h^KK�q�h`�haK K �q�hcKubX   4q�he)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   59290896q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq�h)Rq�q�Rq�hBh3h4((h5h6X   57907632q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq��h)Rq��q�Rq�uhh)Rq�(h�h4((h5h6X   60302928q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rr   tr  Rr  h�h4((h5h6X   59748512r  X   cuda:0r  KNtr  QK K�r  K�r  �h)Rr  tr	  Rr
  h�h4((h5h�X   59863600r  X   cuda:0r  KNtr  QK ))�h)Rr  tr  Rr  uhh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   5r  h�)�r  }r  (hh	h
h)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr   hh)Rr!  hU�h�G        h�G        h��ubX   6r"  h+)�r#  }r$  (hh	h
h)Rr%  (h2h3h4((h5h6X   57917968r&  X   cuda:0r'  MNtr(  QK (KKKKtr)  (K�K	KKtr*  �h)Rr+  tr,  Rr-  �h)Rr.  �r/  Rr0  hBh3h4((h5h6X   58501856r1  X   cuda:0r2  KNtr3  QK K�r4  K�r5  �h)Rr6  tr7  Rr8  �h)Rr9  �r:  Rr;  uhh)Rr<  hh)Rr=  hh)Rr>  hh)Rr?  hh)Rr@  hh)RrA  hh)RrB  hU�hVKhWKhXKK�rC  hZKK�rD  h\K K �rE  h^KK�rF  h`�haK K �rG  hcKubX   7rH  he)�rI  }rJ  (hh	h
h)RrK  (h2h3h4((h5h6X   59863696rL  X   cuda:0rM  KNtrN  QK K�rO  K�rP  �h)RrQ  trR  RrS  �h)RrT  �rU  RrV  hBh3h4((h5h6X   59107408rW  X   cuda:0rX  KNtrY  QK K�rZ  K�r[  �h)Rr\  tr]  Rr^  �h)Rr_  �r`  Rra  uhh)Rrb  (h�h4((h5h6X   59107504rc  X   cuda:0rd  KNtre  QK K�rf  K�rg  �h)Rrh  tri  Rrj  h�h4((h5h6X   59764784rk  X   cuda:0rl  KNtrm  QK K�rn  K�ro  �h)Rrp  trq  Rrr  h�h4((h5h�X   59845664rs  X   cuda:0rt  KNtru  QK ))�h)Rrv  trw  Rrx  uhh)Rry  hh)Rrz  hh)Rr{  hh)Rr|  hh)Rr}  hh)Rr~  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   8r  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubX   linr�  h)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  (X   0r�  (h ctorch.nn.modules.linear
Linear
r�  XL   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/linear.pyr�  XQ	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, \text{in\_features})` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, \text{out\_features})` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['bias']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    @weak_script_method
    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
r�  tr�  Q)�r�  }r�  (hh	h
h)Rr�  (h2h3h4((h5h6X   60760336r�  X   cuda:0r�  M Ntr�  QK K@KP�r�  KPK�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  hBh3h4((h5h6X   58447568r�  X   cuda:0r�  K@Ntr�  QK K@�r�  K�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  uhh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�X   in_featuresr�  KPX   out_featuresr�  K@ubX   1r�  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubuhU�ub.�]q (X   57907632qX   57917968qX   58447568qX   58501856qX   59009984qX   59010080qX   59107408qX   59107504qX   59144848q	X   59223328q
X   59258224qX   59290896qX   59554016qX   59561200qX   59748512qX   59764784qX   59810416qX   59845664qX   59863600qX   59863696qX   60302928qX   60760336qX   60784576qe.       �҈>��Q[�=��>*+�ڞ�;��ϙ�=^��=�g�9=�>�
=c����;���6>�(�%}<�	
�4�z=�7>      �V>�\�=��!>�֠�y�����=[��=}��=���;}Ǥ=Ab�<Q!���s+=�s3>@f|<tP�W���� �+����"j�0�ֽ�Aڽ��K���۾���;5!H�EF��FY=��z��=8*�=CU��8�<��g�8�=!�+>)�6���i=
煼��5>�y��}���v9��n�>X�&���-�K�L���D>=?�<�>#cw����=�l<<� �=����
a���t1�;�_�=C��={��-�a��f%>Iv+���*=� ���@=�B >m+!>ĨC�zٽ�\L=+��>�����ƽЂ�(�>���!��<���=��=#�`>8A6>0�R>wK��쫻���<�iDνgy���{�4�i=��p>*>�~S��g�-t���н|��=�=�={�L=��)�Q��=�]�*(��;>����W3�=�=��μ��<.⹽Ն6���8>[��=�w����(>�� >�IT���̽���>��佬����|>Wܾ���=�T8=� �:
>4�<�H�>0�ž��1<5԰�����`��=J4�==���L���A> 
>��&��>�=0υ�^����J뽮�
>�����,>�� >rJ�WѨ�����3�� <v��V��:=1>��=��h=~b������9>zQ��n���g;4?�<����ǄF�t񌾫a׽�6,=�n�=
@�>�g���X�=mS�ok:�/��VQ��S�>m5*��]����<܈���E+=1��<��.�U~%��X=V"�=��=]����F;y���
�t>Fy5=�k��ZC��x7���>>��<`œ���}��{f=�λ�>�/���=��Z�0>�t>�e2���h���=ub���;=J$>hʗ�WO=�o8��&�="qQ��_��9�>�UM��K>�=�C4=�=�{<��)���=����=�*�=�>G(f�[%P�����>V~��E����Z~)=%�>� 8���=|[b�x�C>����7�z=6	>�ɀ�/};>���Ͷ=�Ņ���>P�M>|�b������*�=�s�	�<Gc��1)��<s���D�ҫ��)>pX�=�3��s��;3>�k�����m� �.�E>��ʽ�ձ��<��D�� ��뛽,9��s���*���&;È�>����'>,� >2�἗�K�7�L<���^�S>�o���D>&��=C�>t� =�,�=<kݽ ��=3�
�hB0>jt�������=,��d ��������=���e>�<�Kh��>_�=\?���|��_Ƚ�!��b��0�f��=��->R�3=gw�<kн���=iI��l	��.>$�<�!��k�սt�}�����=��i=3m��Y�(�R�Z>��4���T>Z.W>�X��`���)?�ipý��<��1���Yr>�3|<ɑ�݂��r|��-��>��Q=���8�t�
)>w��^4�Xh�>Q��_Q�I��HEE=�2	>�(V=��<�أ������n>�/|� Mҽ|��<�n�2��Gvֽ���������=r!�=��(=��^ɪ=R&�<v�	=Q�%��9��J$>_�=�_=n� >��˽@$m>� *�|׃�P�4��IվȾ��������<�"��jcy������2���>�ܗ=e5=b >2:;����"�<�����՛�Wc�<�d�uw�=��E>���=�o�=���>\k��8��/��"O=	^<(Z3��2��W��҉�=6��=�_>4%�S+�g`?>e=>mڪ=���g��=K?L���;��'�-v��_~)=v=>[j���z��-�>�娾	��A>w�\��҆>��=¨8���h���9�������,���>��=�Ͼ��Z����=��'�*.�=�Z/>�]Z��u>6�"�ӈn>����E�=�����=3��=����Ѽ��<�O�=�U>2������������r���!��`����V�>�~<�@�=��<�+U>�˽��>x���yFھ�\/��?�<:���o��l��z���>�i۽r��b�)>�� ��>;�d>�m���W>��> "<�^�<�dq��KZ��U���i�=k'�<?��=�8�=��ͽ����нě!=)���g�w��-����<���>��{=���=� >/�<�.<�ZV��<}�=A�>�uQ�A�+=# ̽L�,���ս���=�<��M��y/�u�J���3�@Ԥ�O��<:]�=�Cd>	��"�B-�����G�<����.+�����0�=��.���= i<;�;r^�A^�xx��1���UF��φ���d>5x�>�$<1��H+H=�]>�KB>�����=E�.�h�=m\[�1����i><��!�P	2>G�ļ|�&>�=ՐW=���� <5<=Ԟ��+w<#.>WI�,q�<]KP;X��"��H�>���<0��=,�6��޼����,�<]>�e�=�p;�nr8��T��?z�&�F>͝T������̴��"�>Ƚ8CǼK:t���{�11>�ɽ\CļvCR��ܽ<�j����4���!��=!�G<�v���>��=��&�����R~�=�����=��;���<:uO>jp�=wM<,`������=WHp�!	=T�*<m� >�3=��W���������YZ�ʥ>�J��H�>)�^�����,�=�<ۜ-��DM>��=Z�->B�K}��y|R��e����>�=%�G>�K_��o�=�9����;g�v��@�9�M>��F��s=��>�h�>�(1��n��[	������Q���l2����=������=��侠��W�=[.޼���=�18��=�=*�ü��&�B#�<�`�<��]���n=:��=�ؙ�ġ�=λ\=Y���/�=�+��ۘ�=i>�����Ͻ��A=���<$Hg<m�^=95>',�����$]F��]�2<��O���x����=N�?��-���:>�����[L���;a�p����=lg��r�M>�=�=2�@�%h��1��>�چ�`ƍ>S���}1;v�>�jQ��^���)�<d{����=dTb=�_�<�N�������!�ƽ	G�p�'>�$�)K�>Y���0>vA=�,��b.��jb�g[𽯴V�Re�=̓c>�싾���ԭ==��}:��<��V�Dr�=��>�f>�=Z�>�>�'R;�e�=��]���
>9ݴ��Iu>�+>�n�>rM����>�����<��"��=��?=27>���@K���.$=&=�MX>�ٔ=�ϼ41C�}��(�F��ߊ=�T�&�?���j6�>�dн�pн;՞�hW@>�F��#B�<��6��� �2�F���g�Js2�&Y�=.7R���>�Y>ѯ.��T�;å=a>�Ju����=+->��߼]���Nt= �@��,��x�U�O�w�=���b��唫<T�g=�1�=u���k�>����Љѽ�䴽�eK������Kd�X��=c�˽:�<��s��< ��ȝ#�dx7�-��N�7�u�E��hP���(>̈E��N>>�DX>�
�=�<nb>=�������)`�ly��h7��c=�n=�+P;O�=*X��мG��=V���S(=<��#��3@���r[=���[K�'��=��<}W �ő�> �o>p�Q���M��7(���]>������˽V<>�U���=~@��<�H�'��=�a½��%��l��/d>�ҵ���=�sD��@>y�>0F<���jO+����l�=�������MJ���=!:�=ɻ=ѽ�>�p��;��#�]䘽(s~=��&�)�ME��E齁�0>]$=R�����r>�<>5�i#�
l��^��=1�>B���C˽$=�=�٬�A��=�DD�aao��S���S�!>� ;	�h=ʎ��<P��=�Q-�޶�<0B�3�Ey��F5���8>��k�^T2;g	�>V\��t�=:�z�=,[����O>�1,�j���?�W<��&='��<C�>׀���I>��P���߽����{������8�^ �<�E�u]��oq>oAJ��ez<%��J��y�����RCb�̻���=#�2>ې���s��t�=GD�=�y����5�1���Ž#A��n���%�9�?�g��=2��3J�<�e��F�v~=���=�H>�U>��> �>��ݪ9�p��Cw��LLR>�����#��U��=��U<����
�������ƾ�U<8|1>?S��.ȯ�z�	�@��<<>�F>Е�=��<T	� b�n}=�=��t#�\5I=F	&�x�m�x�ӽ�4\����<�.>=f��D�=�ʗ��Ĉ>vc��')=>PM>􆨽���=�۽h�� ��¾9�[[��RW=Õ�<���=��0�>�|<z��)�;mTѽ<Vɽk�C�֋��&��=�;��X>�����;{>aj>$3N=[="�w�=֮x=,?#=/��7�t��ϼ{��=y�3���<��8>����#x�x&1���=4|��'^��/�=������<h�n>�ֻ1���ʼٲ�=Vnҽ>\ƽG	>30���=T����+t>�$i���=晾�i=��UԽ~J*����	<9�_=n�a>I�<u �=1Y>C�cTI�樽#9�\W��Ρ���
���>���==�ɽ��o>�Ѥ;�?P=� m=jЉ>�������=���M�����=[*�=��=���=}��ĴI�� )>�3��;='-r>�.������>B o��w=�U���`=`l��A>ӿM>�YE=�2�<޽ߢ#�<�={�\�&
�uډ=�:=G�6>���<��=7>�p�=�
�Џ�=�/W>( ���5���=�>��ܽ�\�y���*>Y>�%��Qh�I�=0�X���D����=�Ҽ^O=�%=RC2>{+>���i�>�����e�=6D���4�=S
�������;Ҟ�=�;nHG�*8�������Y����}�<�A�=$G6>�C>wu�����>浽�=�6J�:�|�<���=�%t>����/<�?�=����E�<��H>A.仦?�=�'8��/V<�����Z�>O��>R�f���<�A�<�@>���7<�I����ڼ��ݽ��>h.����u>��=:1�=Z뎽^�d��̑����UJ�zQ�=�K�����F�#=Y��m�<�aJ�N'�>SQ��)��+>�0��+R̽���=_�C���Ծ$���=���>A�X=W�@=���E�<U$	��z}<�9��N��9�2�;˜=�ɩ�&j�=�/>���>#�=\0���%+>���=�8.=ذ����濱<�r=�f#;I ���(<mJv����I,�<@ǽ����X|'�������S<~Jx��6��}�R��>R���X=%�a����>�����@<o��<N�۽w�=�ɽ����{�<��t=�=�^�=��=2����#=�=j��<�hR��^�+y6=R���䝾7��<P0y���A���üY�I�m��>0S�a�d��=����I���;�Q��`^/��]6�m����5����Ͼ@$7�3a ��ջ�=[����>EKH�L6�G=����E�p�>�>�=�
@�8 �=�oS>����5@�O��;������C��ɼ.���*�=`��W�N��f
9>��G� �-)��^�<`�b�Q���rN>�n=�O�׽3m��=�=�%�e�V;�=(��=��=[1ٽv�?��8=��n��{U�'��<�fC>%什��\�\	=&��.U��Z|>��>88=���<rݍ�^�;M8�e:)�W=�M=U½)���3��;���]%��i>E~��������:گG��#>= �ּ����,�򼍄>"��=��L����={'־�A>tn9=�LҼ�#K�E��=��7=��|��#��q���N�g����ZU=�o�.���8�j�+׹=K=UcQ�׫�=}1>�Y����=(q$�.d�=��z=h�_=d�)�8L�=jǽ�D������I@='F�=r*y�fp�=����@T��h���ً=A��>�G<�+��$1�Z�=�u��|�<w��<��@=\0+>.�༕C��z��Uq��`:��㬾n�<<[ >2ߏ�V1�=s��=�'=a�=%ML��}<��>v;ս:���H�n���=��>!��=�>)<��<�3CX�
�ܺ�<��<��A���=���ޘ����B��Hֽ�Z��%b��<�&�=�芺2
>Fb_�����J�6�M>t������p��m��(��W�>�e�=/�v>&.���=�v�c���!�˼�x����>?�� ->��A={�=|J�L������=��/�l��i>Y���\w�<�%�IT�=����poz�;�p����=��>q���i �=�;>�ί�j�R��Gƽ;�=>j��z�>.�e����<Eg�=ly?>N����Ӽ�5?>��=�1�=q	p��ּ��=/IY�<�*�_$�{}ʾ	M�=�;}�>����b>'Y`�ؘ��(ph=p���~�K{�>��;O?;=���=�j���6><���$w��o�T�������M��A�G[�<�>��������	���Ȓ�R#W��{<i��<�Ñ���w�9(ý%ۺ��
>�=���;W^R� ���*Z$>3ʕ��ӕ��{�=��6��国S���~�<m[�T�>~|�;�3X>�(����O>�=s�1]|������=xWB=L{=��0�6�_�G���B'>y�d=/��=#ݾ������񙽢�'����윾�qֽ#���y�=�><�y��ر��h�������;ʬ�<<���0��1�{S�$��n��C߽����'���?��%���mƼ��>��{��5��1>V ���j�W��Zc��Z��ܑ����܌4�F8�:�q�4oϼ�T�ƃ	���>@7=�#��a�H<�5��-	>��U>��3=��=4�?��,�3���?U�se�=�7R>�`����q>��̽�ؽѤϽ�ؐ<��=��̼hg���T�� M��nn�<�Xq����>�Bt�����Tc>�0�=+9`��Y=*}��=�i��h�>�а���={�ì<=\�b<�ཱུ<s�:\�;)�$��:)�6����`J>]��=�]��ʃ=���=��żϊ��ٽ�<�j�^u=��ҽޞ ���r}�<Hދ=�ԽA��=s�,�o 9���
>v�a=j:���'��/�=��V�Wŭ���<jг���e���-�(�;V	
>�%
�3+�=!Z��/�B�����F���f4����=��I�l�Tu[��-��f�g����=�=�҇�>��;ujY='V`=������=�7K���>�Q>z�G�g*�=��U�<�V:���>^��>3,�=��ľJ潿K�����=�e��?�=���=m��={ۋ�0��=[�ʽ7�7=:��T�>���mZ!�=��<�p�����>�{�=���^�b>O\P�ϥ��;��>��=�e�=���=l�O�Ƚ�$����ӽٺ��� ����2=/D�>�Xk=�T�½t�8#{	=*
v>48��@�Ѯ�%��-8<�*�=��Ǽ�0&>��p���S����g��K{<{) >|Le��g^��f�VO>n���B>=�x������X= ���F���o��<0 ������R�A�����ֽF�/�Cy>Mm>�H�WﱾpD�=���Q��)Vz����Es�!�$=:�= �ջ#���W	b�dS����G��Pp��V��U�3��-Ӓ=c����=i�{�d���)��~1>j֋=fr =w��k��4>�0-�Qڽ��s=�o�����=H���%���>�ԉ�c�{�[�&=�!~=�B�1;�9fK�	
��?>nZ����=���:���>�=tJ"�z��<f�<�&�ڑ��;/�>[q���v�5������;&�=[{�\-���-��Oм����� =܋>> �R���W�CG�<!92�����D9��E�EyN������F��g��Ó��\�e=x$�=�'@����=} y<(�!>��=�E
>T�ܽE�B�^��<��=R(7��$��m�t=~>�=��<M6�=Vw��!�=eu=�&E��������I�!yk>%w���G�=�궽��=��h�u#�E��=��:�;���;���d�T����5�;���=�m|�����B��$�󍞼<))>������h>���>"Pi��6Ѿ��>�bྋmмll>o���y/<����=��P�;�P���>�p`>��#=�徼!�=��&>(S�^���X>�/��	t�>v9C>�͡�����?��=m����U����R>�MW=������m���>><��V�I�n��6��%���>ϙ5�QI�װ��E��
g5�*��<J�=�B_�+U=���<�"��=���<�9Q=�G>) �;�&�dހ=C8a�3�;>��#������R�V4=ߗ���ʈ���R�gB�=o�="�=9h��1�-��nI���0�-��=Wee=�V.���A�;ȧ�<K��=9�3=��=W|;>&]�ײU����=�:�x�ź=�Ċ�Ӷ<�O�9���D��;a=�F_����=��<��N� ?����~�L����ܼ����~�~���<�<�j�4:�=�@>�� �����gI�>���q��u�<q��=$[��2=7�໊��=AwJ=��d�X2��A��|�����=�(�<����%�wU���˽?�>f����lg�=î��'1<���=�B�<�)$���>Zû�r��=΢?�K7��ߺ��x�=��<���vH�<>�w��:0�AJ�.��<n��=]逽�DK����3M=[���^;�d1��C%=ث<�++>�J=fMd�	�]>ib=y��h�ý����]`=�W�=
%>����L >"�-���+=g q�0  <�b_>b�C�X�=w����e���>��q=7��-�>Q��k�=��=��8>��`�H"�-S">��>��Y�=-o�@L���=��R�������!>�˽��v�e��c�^���:>���ׅm>�Q	>:����9>�g޼ BN>��B��W�����=Ͽ-=1��>�ӯ���,�x׾= !1�U�*=�x>�+`=62��HŨ>�1���ژ��3�=ͦ�5���?=<�;D<��->�Tx>,�����ܽ{����������"��Eƽm	D=/5�>A��olb�A�>��F���V(�r��=J ��r>� �=�\Ƚ�R�<T <5eH>�W�=\3��X6�uؔ=j�	�۽�vX><C�>b2���c=/��>0�*�'yL�:@�=K']�z��#
���5��Ƽ����/x�����To=,�>]%�=�=.e>ĝ��Y;�^�k> �
���&;�J���漽�����Ҝ����:"��|�-���%>�=��ƽ<�)>�Q��#E:�*S?�L��=il>�Q���`>V���)z���9>]K
>�����3�=t��>�ؾ= ���ҋ��Wn���K��o8>�G�:���]�=7��=J�g���O�E(y>���$�;���=�/>x�<aC�=i���~'@=:���:Cн(#>��@��"(>%�#>O<�lD�];�<�=�Q�<
�:�0l�t}��DO�zW>y*�>�N˼�簼ų0�lk�<ޗU���T>��=F�=�o��W���5,�����i��=+P�W���SW�Ft�W��P=��`t=��;�㻍�a=}��=�|8�V��>����~5F��>�桾R�e=z�Ƚ bb>�����=�
��=G��;�9E�8� �&R_�T��� ���>�=ϥ=�>��;��>�5n�0��=��V<C#����;�\�;����R=.G�=�!>�L�=>lͽ��=��A<6��t;�DѼ>�ҽP.�>��=������>��l�)<�L�=������<f<�"Y=:�#=�(�=�^2>�^�<g�7�:�F��	�><���<�L>6+D>�8��3>D�L<1%�=?{��1s!>dkl�憨��~>&�ȽQ�����=��=;�Ck��$]�Jr���E����<�X�<'��=��?>����ψl�w��<=;�AϽ��=|Lg=>�W<�:��=��t>^D<_}�<"�;p�=C��;�@Ͼ>4���n�襇>'�Ƚ�m�d�c=��ܽ�>Y�(>v%���p~<�w,��\�<���=v����b>d�t= Ŋ>)��=�@��X�=�Ӷ��
<g��3����m���e��%O=�T�=w�����<줽�*�>3�_>�V2����" �**�</�>&si�<h���{�\~�=
�$��id��+��ː����>��6�"w=�/��ÀB���н�E=�P=njD��>3>���[�ѷ�O>fmo<+凾��.�9޼=
��>�O�=�q=j����#���<)��4S ���=��=rH���3=L�>ʵ$�o�<�ݔ=Mo�=�P=%���<�?��C��0͖��Wo<�B�����.>C�=�a(����ʕG�]V�\&W=�~�����?:,�>/��<ӟ��%μ̊�=
Wu���k�*�A�c$=D��� +�A���������=�������a��<�U7=�G��5�=\�u=�R;>�މ=�[��w%=$�;�*%�$6D>~�o��*�R��͆���T�<�3\:4�=��,��>��=���=�������=�%c�3�(��/;?Ә=�=�]D<�2���*�Z�=
>�%�I�ý�2ż�E3>I<�=S�F��^
�D����<��=Ko&�*��Zt��K�=W;=��
�б�<PB��]>�
Q�T>fM��T��=���6.�=�=�=�:�Јr�ϜE�j==��S����;��=���<cV[=IJ����=�νŽ$�S���f�>Q�e��z�<�-P�dv�=����u+���f���-ȼ\B>���=	��<�z=X�Y�a;�>�{u:��ڽ��ԼnN�=-<;�f>�n	>�"<�NԽYQ�@M+��ʾ2k�=����l��>��>7Y���GF=� ��q$��o�Z���L��>����K���>.=�B����w�>�4��;2�m��qG= �=@0A=�O&=���=qS=���=Uy��pk��S{�� >r4�wNU�&q0����=��׹��F�ˇ�/L"��_=�S��S�!>8�=�R��=�����|�Z�����Z7>��P=l���KOW������v'='>�=	L�=����v�<!2�<
>{���y�!��.(I>�UD���P��O=l6��L=��=��R�>&�R�`�q����=�׳=�+M=S�����(<�j�͡�¡��o�=c�6>&`�=�>>��X>�$=$޽�R_�m��A�=�f�=����:��=�nJ���ʼ<m�=6�>T��J��<)�ɽˡ�=㵠=��<�:�w�P�mٯ<N��>.�>�Ľ���<�1=��@�`���OE>(�O�#Ƃ�}-�}vw��ޛ�1r<����	]�A�=\A\>���=��'�c�(>���> �"<����DG�������C�>k��>D>af�=�콂�/=�1b�Ij�=YV���`d=}->��g�#Ύ=|����:���9��W���>8��b��<|���X>��U���D=i�5��z�;ve�=���:q;ýJ�~=�Ҥ=!������NC�
L)=x]�=\�=5�D�ݽ��DZJ=Y 㽋L��̥���;�>w�>��;��V�=�=9ߞ<神>�@�=�᝽�ů=���b둾&�=LA��DH�>���>�����V�<=�=��?�ځ�.C��y�>�8��7{���>:���X�G>	W����9=x�x�[ش=��T>� ƽ�w����q��V�����g㠾Ƒ���y;�mO⻕��=4���,��y��=%��<��<�>R�B�2��=Zރ=Y\�� �<��>�=���I=�X���i#���=�=����	>}# ?���'�=n�=�ߺ=3������=��H>�^��Eϒ�3���Z�սLP����P�� �=��ϽKe�>�{��������#�>fj>�C���8[>�̽��_���5��vٽ�����r�=Cﶽ�ֹ��Ł���L95��<7X����
���,��XC��P鼎O�;o>����`�x�m">'��=���4��: >�ֺ�o���aܽyEB=9�=���>����A���n��M�㓾�V�;k0�/�">+�=���TIۼ�O�<�0H���}�/G�=w��=��%���� ���H<_j�9��<�d�;���ׅI>�>x��eո�����>�;��<���=�G����"��̸<~m;t�#>�{�wm�������G�<�J⽁E<E�=�/>Ic�����=Ρ��1r/=&,�=0i$���Qw�=�4�|��<z�9>`.����U����O=�<;ND>#f�������˽������=����k�	��8ܽ3>W�=� j=A8�+P��I>��>j/�H����`[>Ǯf=U�1>�'g�w�`��.>�7>a�V�$ x�JS<�M�<��<M��j�.`>�'K=.Dݽ<��<1��=�l�<{�޽�!н� ���|��E%�V�P=�R��Q��=x�=Z��ЦV���� �Y>��>b�伜ܑ=�MO�$�6>�!�="������i�4��þ��8�w����9��?O��|�͐e>���=!d����5�ef������5ɽ�J�>��D��3Ža1����x����=`pg=p�[=�սQq���-=��3��3���8%�2S�>�̢�W$ɽ�2���4�:�� �̻�����j=w���An>`@Ľ0�M�l�=�j�<����D��?O>xh�={�}=�\��� �O����S��n �=��h�I�!����=�L*�W6�����᳽�'r���ܾ�\G=�����=
X�=Ԟj<O�@������yT=�����*�>jq�=L�J�=�潡#u<S:=�K�<=�;�Db���>��
�Lu4����c�,=j�D�(�"���
�
2����a>�9A�%�=١q>)�����s�p����w�=�>GC[�d:��<w�=�b��& �=��;j�=����ʹV�I�YK:=�k���*>[+Q=�L�����-��= ~�� =
�P ��إ6�H�伌^��A_I>_������Ym��Z�=���<DP���ݼv궽 K��ef=% >0����z<=�WT�d �Z_��BI�=%UM=��-�����ڽ��c�q�F>cu�=�o��a���i��=��E=���=�k>���<X�=��X>���=��r��!���V����=��=MH�=F��i��=�b=�#�}7P>���=0-�A�n<P�n>N��z��0	:���@�^>X��=`{}�V^:�GO/>P/���O����:}e�=��>���=�>��l�S(	;ϓ�<W�=vy��4��&{>W߉�z�=��#>� >\�K>��}=��#>��5��½�v%=�>�Q+�l�>�y<S뷼���M�;�N~=9t�=Y��;���z��X���OZ�<�W����=BB=���<�o���k�#��Q�i=�-�<�a�<���=G�����$C����=���:��<�i�>�Tj�����;����1���N���j�ȝ����m=��=d�@=�0*�!!�>�k>.!��B�ͼ�L�>Bx0>Hǣ<��(�#��=(������;Q���]����K�>���=�1D��pC>�н3����=�K���r��v�{�Ö�=�r��;��=�=�<;B���l�0�������q�K�<8��)>�(�=��$���-~��~=v/>��<�>Z�1>	 �Y�\<�>�W	>�0�=�׵=l'�����PX���L��>ƴc��Z��˟�u�:�R���_��#���Ab>��L�!�c=���g�H�]eM����=���*�<�ށ��+��'VO>�@��=�����=�����̽�X8<e����*�=�lĽ���і�:��;s��=�XL�b= �k>
d�l��=���ד�= �=䶰�W��=f�7��Xu�%jR=�-e<�lj>:I�=�r8��g�$��=U����/=�`P��ڌ=��Z=�����ӽ/��=ɢ�<�6����i���=賂�<j���#�A��<!��=�r)�>ݛ3�@       c6>��=����ŵ=��<��=^���]�<���=�
�`��=�`�<�޽��=�>��
��>X[=t���Y�M=�>"T�2�}=�e˽E>g����=ә">^��:u�A=��=Z��RJ=̄;>��=v�=}�h�-LN>Y�=����.1=Gp>s~���< �et2=$����u��b=��<��f=�kd=���H�=�c*>W� >�ӕ;��P�<�'>���sE=Z@Ž�Q�=m��<U߽       ��=��6�� �=Fګ��г���<��Q�ݴ|�� 켗��=4.���S>4��Z-ͻx��=G�=��Ҽ.�нp��U}(>       <"F?���?o2j?p�?�T�?�[?�(q?G%�?�Xw?#�{?��?DGO?{��?�&f?���?��?a?e+D?�?�ń?       X٫=>�$�޽�/>���=��z=�U
<��6�����p��=�t����>ţ���:޽h���>��=�����kʽ����       ���=�>Oc>��=&>"�3>�=x>$m�<���=�q/>��[;�w>���=����H>[��=NVY>��%>���=��=       lJ��ޗ����L�_ɿd��m ¿���m���X������Ӫ�W�]P�)I���W=����E� ?����$���u�G�       2��m`!>�L�u��<':[���*�W��=wS"�E����/9=�5;�2;M�3>�N�= T׽lp!=�g�=�e=n^e��Kݽ       �<�=� νj׽�>'�
>I_=�P�<~����jm�M��=��)�>�7�GԽx����G�>�=`�ͽ!���|�      m����P�e) �/��=��N=�ؽ�PF�N=����O�q�g���>}<Dڶ�K�=F�}=��<rg��f�� ��=�;��GH��ؖ���"$����=��l��eE>C��	t���j�=���=��A=�D�=ᛒ��K.�{iH��h���μr�<�yf��49��a�>���Ȫ��؝;�۹�x��H����g=�M�=�U���^<�d7>��%=�7�=��Y�*���Z̽��w��Lk����s��;8��'�.�'�w���m%��L=q���f��=��.��m+��>U��Yu������s�����$��g�;U����=�n�<�V��QL������H��Z��P��P�K>ikν|�#�h�.����=��м�<\�S����A\>�^1>��=9!d>w5�{Ľ�tO���=&9��	>��=s�����=a�'��>"�h=��<s[�8fH>���6e���V��½�ٽ�+��V��2i	�4��=�32>��9�P���{�Z��=�U]����=8��>�S_��
��y��=BO>���QC=���M�=-3f=��<�v���̝=]�=[���y��}r��:ͼ<*�=$�>�=�o���)��=�������<��	;,M��s K�g��a5$�2V1��`>}�<l�=EÁ=�7��� �Uiz=����&��=����im��A���6���Y>�>��پ_���:v>�2��+����c7>�I�=�g9>��{=u� =	?�>�.n>D��Ċ^<G>о=~4N>��k>��O>��g���>>�s��K����R����4F��
�=���=�5=}�����Ƽ/�G�%����:����O�n립0���K+&�?�F����=�<v��Q6�u޹<J�<�"p>��=NX.>�U��2���:��h޽���r½Č7=��=
������>f��=�N�<��:�=��f�C���+�+���=�Z�҇3=Q�����߽�&ѽԮ�>�Q#>�L3�Jm�]�F����t��=��6>x��=� 1<g4�==š=B��<�x��
a�(q�-�>*Ņ������z���Yv�L�=�u:>�u��� ��l=�C�=o-��3�G>?G
>&Q>40��V�����ܻ�o����=���Y�����=����:��{�׼K�/��B>`��=: >�n�>x�>O2>�u]�� >��:><τ<-�q>-?�=>N�aiJ>X̪��P�V�N>���������v���m�����j�>^�
>����_.=:��l�pܶ=A�=�j1�%0=�R�=fL����=�<�>�p��W�=��>!wJ>��<=(P�<hޙ�5"����`�"��<�%�=�n��� >�K>N�=�R>]=Y.�=�>���= �4=���=���=�����N;;�&=3F��/ƽ-��=k"��])��tR!>Uߨ����0�A�>�8�mk�G*�s��N��#-�mG>d���W�>~PJ��U�=r2H=�\<����G'J����=w2m>p�=̭�����<>���y���������,P�D��>W�=aɐ�e W>��M���=1���T��DA�=�yžo�(><r��1ے<�9�m�@��t���B=7]�=�C��*8?�i�����S\	��[�O�?�N�I���R=�ʴ��*G=�So�ʶ�� �=����x�">�Y�����5q	>s��="G'����#�?���=V�v>��I=I5R�_�����=s۽Qr>=,r��<h�">V����ƽ���=�8�=�r ����<�\�=n'��7��g;�<H��=f7�=�5�=Y��=<P�>^1�=X,,���W=�:�n��=�Y�=��d/:;Z��=�Ҵ=�����=d*>�)2;��9����=�s��棽 ���GM����@1��|�ϽK.B>�(��jR���D�wĄ=� O>�{J>�н6�=I[W���P=D�K�(�b������ю>���:FF�=��Q<�Xƽ���3e� ��sZ5<�K�=v X>rOM=)o4����{�轋,��Ͻ=���q�R��=no���*���Tv�� ����2���={�=V:����u�t=�> 4��0�-�>�&<�B�0#�,�I=B�q=�R>r���2S�GL]�*�3=l��>�4���?<H������@3��Z=�7>�� ���=�.&o>����F�@U3�#���:���F>���=�r�=��b�&�>�k5���(�>��w�C>;�=!2`=y�|�� �=�;��A�k���=W���3���<��F�>k7�TZ�Z5[=�:�p)���Ѣ�LX��/@�/� >Y��=��νa͛�J}�=ݼ�=�>p�;�$f=(�"�G6�=̱�=&B̾d`�������b�����=��> M=J��"�>F~����:�����H�D�V�'k���σ=��`<>>�m>�"����8����9>ȺwNŽ甿<|�<�QtV>uH������?4=@�!>���������ℼ�I�|��=���=9�=�U��Bn>D�&>$�n]6����=�>��=��=l#>D�?>�pּ,�A�e�R<i�=�V����">K >7E=��N���>ך�=��ӽ$m���=�3ݺv�����=��c����v�0�>�v�s���;��W=mE	��̊�*��Ô�Ǣ�_x���oڽ�:��F����#�n�2�?�e�7���ѥ�=��f�<�)>�o�=�V�����I��=�3�=~�=f.d=օ�\(�>��=^ ���˔�땼;�&����
;\g��N�\= \x=�\	>]���t��;��\>L
<��E�2���9>�l��R��->
�:�.�0:��B���)5�=63)����=P5+��y�=�����<ڶ�}�Խ��\��?�=!���,��S�*�	6E��ķ�oJ��	����]��%���b�>i�ȾG��<p-��ѽYNw>��<>�)�X8	>Cx��f�=�<�J>�>�>"!X�j��=�� �0�=�Sb���g�����x�!׽p�佘�5��+Ƚ4R��if�=�;w���L<�*���5��4=)�`f�>�J�����>J�=����н���㬽g+Y>����O白����櫺"[X��.%�[�=A����=
QN��C`<�E��+�>��#�m��=�hA<6��tH=H�����}�=�%��l�=W�����5>�B0��"�=2��=����� w�U��=�`ػ"<��Q�=j&�g�<i��R�T>6$;���=� �<=O����>>�sӻ���>��E>�ݘ�^G���=Rw�=���=-������J�>k����d >�P��ü=m�_>�O�>9v$>iM�=�Y>p�:>����eg�=�@��M���i>�����}�ʽ�6�<ŗ�>��=_#��@&�(�p��>�Q�=��Z{>�sN=F��Q��=t��=eUQ��#�=+����'������p<�����=j�>�8=���=���>��ད4e>ⴚ�T���O��;Խ��=��u��	�����mTP�KL=�����o=dI����=�cp����=��L>p%��8�<�Y��Y~)=jڼ���=��Ͻ*M�>�<i>&�>�s�>��e�&�⽜�߽>��=s��=�P��^�A	��u���==�v~=f��>x�>C%�g� ?�sV<wp,?NU�>���=���=��K>�:�<&*���y>�Ф>�h�,ľ>f����+=EU���=�s��5�������A�=�&�</����YG��# =B�����:�f;�?���B����޾Y�U�}��l�����G&e>?�=�Q�<�'�������=�M�=ꯀ�Q����)=��g��=��Խz����!��{O=�N,>�N�=5Q=j�~<R�I)�R[��A=�F�0M����2�߽�K|�>̻a>Ϙ���-�����g��< *<`ٛ=�@="�M��s�>M��`X&��FI=�╽{�ƽ��c=�W��� >�	�=�"c>�5��'��=1� ���4>3�<��+=���=@��=�e��O���[|=��==Cu�y��=�ｉ�[>h
 ?2x?�@>~��9 Y7>�s�=�-��S��^ͅ�����W�k�
��v=�`�y�!�>�M=�kҽ�K0�S�:�?�½n���Eq�<��k=[�½X����=O�=nؤ��+>�<>Eѝ<�����<�5>� ��7S���>5Ľ�ҷ�Tց�mо���=����[=��������^f�=�$�9�M>��J�7w��M�5>k�/�^���]>�н�j ��	Y>n4��ɽ#P-��׈�˂C>ڱ<q#>���=��u=gw>�@G��7�= ��=)��#F=%�G=�����<��=s�>��μoy�>��>'5><�=G��;�i>*q��;J�=�n���j½C+�}1��+	>�H��I�t�&���@�.E7��+='~<�Ǐ=�	Q�c8;>�+�(��4N���hϽ���mu<�����m�h=�<�R�� }�O�R�$�O��s7��7��gd彯ug>V.�==M���?�f�W=&����=N=۵H��k0=����7�v�߽�&>��=��ͽ����p�5h�=���=��!���޼���M6��պ�w>��v�<�ͽ�����g�j>���C��=i��=o�9>�_�=(�¼.ݣ<;C�����Pr��n>��*�W����m��jf5>�)��7署>��O⠻���=��e>}8�<)%�}. �7�>� e>��>=�(<�ܩ���ݽM�=�a���1�$�����_�̙��������1<Ӌ���(>Y{���s�݉���0�Fz>��=���=*-)�3�=*τ�aU��ge��A��t�����.�U̝�[��V
>V!����<Wp6>�b�>�c���=ZO4��=��>�Z���VԽ�-F���x�cQ�<�mV��,�Q�;w���ͷ�g�^s�6X��&�=q�����0s��ʽF��LЩ>��T>P����0=a��=Z�V���Ƚ��;_Sb�0�5>L-i��B�9C!9>gLy����Dx>�e�'�.>�m?�j�'�{�m_���9���%�<��;�G�=�｀�R�!��\������=�x:>Ӏ���l=DǽÁ������|	�{-�>d�=h���=��>�����:%=��;i�^=	�w<�'��M��=�oi�y$=�Q�)�$������,�=�z=����� �����=F<�=^O�$'�Pn���?�`m)�ݫm=K��=�/>�x���-�C�׽�ۼ�+=J�=�w���A>,n>�:�v����?>�����KS� 1>�E���
<�9ټQL>�˾��A�����<*��=FLU;�TR���=!T��f�<�½:���t{=]�Љ���Om�R0�<c��= ���;S���-l=2TY�:�s��j���(��r��$�}B��Y>E=ʌ���K��}n��\=۟T��:վ��\��u'=�ꐽ���<�O$>e��<��5�2�5=���=a�<��;�|�,3���e��q�v�����=�5�=��/�"�\�2QX>�vS>j>�ir4�"��<x�>�Xa�tT=�߱���=3���~�,>�]ʽ
�< �}=Xl��{P���Ľ(�n�J����=ڮ[��o��Ğ>��E<l���T(A���o��5���s<Z�=��=�%=�����%��k��C�+�K���,v�ڪ��h�w�*��;�TZ>ی*>R��9L�J�|�А1���="��=�<D�����=`����W��+�=��C>@e��IO��<>�>��뒽�\���@�_�>BU���7��֫�=/���{>���=��p�'k'�Z�G�G�<�����=rd!>٭�=��="=�֢ݽ��J=YJU�-��=�y��b=>�<1!�=p�(� 캼eٽ=C��=pQo��C�<�Z=�k�4>��	�K͉<�;�����=�=��,��<Y��=p�>��P;�µ���=gS�`h�=+\8�A�<Z�.>v���T�g�q��>=��C˽�����=a�>0�>�΁��=8�Ž��>��<��=9&��{��V:���h�("����ܽC��=�W��I>0&���.�=	b*���(>����l½�m:�L\�}�������s�W�����o�K�����U��^C�<[�q����<����S�E��_�!�>Z�J=O�������U�ü'ܺ=QD-=�@=�#�<"��MEj�x	M���=�ʞ���\��f��/I��>�?:=�� �Z�I>C�����>n���e�<��=_R�=Z�X���z�x���޻:��=DO>S��i�x������ј�>	�=��>���=<�}���>����?��=�|��ҼCŠ�Z��=�F�<jN���^P�&jѾs����>��=X�>�k�K|��O��>�ŷ�����<L�۽��޽�ˏ���=^C��r�뽁�ƽj���=��,>����Ѭ�=C��g��=A��\�=w�1>~�¾'�>Ɋ>�`�҂�=cF��΁=�z����������]g��$>'c�=
uӽwǟ=zv���2�#]�=�\=��a�`�>�,�5Ǣ<W
6����x=��=�(<i����^>� �C��Llk��u-��m�kG3=/\�=�j=>�m�=�>[5����<�I�$5�=X�Ͻ����7�ؽx��<�x�0@��ڼ(������e��+���y�=�5�!	�����=�����-鑾1�ﺟ꽊�ǽy�=���=��߼<�E=Le�=�;�]��Q>������z�5�����>���<��	>�Jz�e�u>�*�\m��������Id>0Y���w=p��>��==Qo<;�򢲾�
[�����̬�<j�s�t���i�>�v���5�=�u�}���_Z/>�
V�����,�=1��=���,P��;�4�2�ѹW%<�0�=~Ԭ=6YD�������L�> �=O/��e=����<�p/>�`���5�>�2�<�y>,6h�u$��(�l=� � ���Ӻ=Z�%�%cA��	�</�t;�҈=ao���鿼�A��=��i��eu=]�)�\��˴�<ٖ�: ��=>(�ѽ����>~He��1�=׃�=Ee1���2=�sY��7���
�=�z>��[;�~_C��ר�V�����=Q�I>�9>�!y>vҠ=�V�>��=6叾�:�=��< �=�T6�zA�=X����4�>���=*]f�u>�g��9M3�2L��>��=O��<u����ݬ���.���'��=�R�=���=���1��u�=��=�FW>����M�<�CĽ �h�=�e��4��=��=E��=�m]���⽽P�>��=G� �G����=)x=4��>���=��k�:>���=*���$�<���<V	>�M�;�Bo���R��w[>��#>�A��?�r���<�]���=�(��3\<r��=P���-h>P ��0>����wa�=��3>�8��ɵ��>y=Y,�=I,~>@Ի���ڽ�
7��X�=�<�y��=^���@R��O��������@	�a�ս�w����Z'�>3i�<]�^=;�>:͞���:;�5�=�J���V>���gy�PU�J��=hZ�;��4���Q���弸N�Ql��jd��f{=Igݽ��q�&G4�ENF���J�ŵֽ^,@�_%���!̺�	==.n��&l%���������A�>�	����Ǽ���� /H�Uͽ�D��b�<KK-�Xf��E���T�=�5�]���c�U���;�
*�6��=f��1�b=،�=����\.�R>ѽr�=>����A\�𠂽|��=@��=��p,�r�D<�բ��u>2�ͽh�;��>��v=FS	��[�����/]��Au>���'��=<Y����P���.�R;w���4g�,D7>�2���x��_�=�VS�;6!G>�p�Dq��t�0����������>S^���ƹ]ƼX��4�\<;���nZ�Te�=��I������=����սn�ݼY�=��y\�e����$>k}ܽ�>�<��=�v��Ѿ��+>��%�W�ɽ\}�=1��0E��[R>c�;�S��NX��՚����p���<m~�=O����x�=�)����=p��=���=�m��h�;�䡽���k�:���<~�ü�G�=RN��ĸ���ѽ�J���=���<u��ĭ;A�³��9�>�ߐ�V��=7�@>}��U�-��=�+=8��=�#J=Q�׽ ��=��� ƍ���=;��x�=vB���D�>�E��O��;��E\ؾ��(�R�G��L=k�μº�=�`�<�l���AQ�ѐ.�[E�= �z>������-<��>�i�!�9d'>�Xv��#ҽ�}�<�Е�Y��C��=%O��D<��=Gy���<�)�9���ĽQɓ=��&�|�k��|�R>߈<=pz���q>�?>����A�n�8�p��و=�T<؝t�|P$��G6�X�#����-�ĺ��ؽ���3�v�oQ=�̵�.�	��qo>�6�ţ�0�!>%�A�D�ӥ$��>̨*=2�5ƽ���4��1`��i�S�>o�n=%�׻ズ=U>+��<���MC[<^�>В^��?��>#�>� 9�*��=���=�-�<|$)���:��/r>�Z=E��=�����V��{J=�]t�*n<���<�s����剿�-X�*��;hپs���n=}�2~q�<5<ȫO>4�,�+Oa�u:D��t��[��=�����P>C�V��&%>�ՠ�~�b�2t>ȫF�����˃�����I0F>DE���!=�o6=hha;��e�@;!>CD���,G�_J�ǜ���[����=�R��?&>�̓���>p��<��]���a��9>>lSս���Pwͼ+Ba�E��=;�S��08���t>��=���=CM����4�t��=�����?>�����wr�k�� (>��T��[t�uk��.}!>s�ý�Z���>Y#~���X������q���N�.d�$�>5~�>x�H�`/F�ӂ�����<���=a�i=z��m�����W����J�ն<v�����pvԼJ�<�(N���+�'�>�G�� ��� ��[{Z=p�G�&,��y>p=�.�==d�=�v��Q==�� ��=�7->;��_��=!��<�Z���������[	�Z6>;��E7I=뇾4xl>�-=~Ӛ����<��k���d<Z6+��4�yCd= -�|��<�F����<Z��=6�'��=�"��{�=r�`�T� >��<(�<�(���I�ǵK>�bB;����U���'>s���H�.f>��=�{Q���>[��;�?l��G�����D�>�Ԛ>k�N�U˽f�>Ϟ^�z=`=ݽ�S=��;>�|��e��UNE=�a��V&�=:t�=�`��(�=UAl<�:��W<K������.z����=�	�S/d�ѝ�=��]��֩���>�)>Ζ�LE$�uɺ�U";�?o���<ZZJ> �>N��w���P�{��W+��<{�N=ʘ�=P��l���=IT�=r�<.�����=Ϫ�n��R����Y�Z�O����ȱݽ{ͽ_4�<\���e�p�Z�=��N>\?��������>����&s=��I<ܵN��	�����=��5�
+m��=�=-z�7���<=�="�:<���o<��P�/V�<�9����c���a;v���R�=��K�}�f���'=�ܫ����=��d����M��C=P�#>ct*�=�>`��u����%��Ĉ=�w��+Co���T����.}�=\�Ҷ �&�R<"W�:]O�=���>�.=�L��.��d�<�	����Λ=p�g��8���v<�-�����S�<��T��r>��:1\�=ZTؼc���B��1Ǿ�.H=t�k>�r�P ���"�䨨��pw�l����u<�Ό=TH�[�=KY2��:>���=�@>%��V�����=�Lk=��:�%<�=�#�����<U�=~�Y�h�(>D=��=��<�*!>K��=F�>|}�=�Ҿ�Ϸ>A�A=� �t���Q޼�B��&Ѿ�h�����>C����н��>Y6��u���z�<�X�P�#<�2!�5��<B+}�w
1���H�dɽ5�[�7���T��>����<�'�a=v}���7�;�/>eO�vIq=�>x#���f>��>�ݔ=�M�=Ћ6<�q���޽�Z�28t=ޯ\>��ȽƗ=v�� }g=#�C��b���=31=&B��� T�i���>���w!=tA3=��F<�?>�NڼR&��8-l�8vνMm��Iw�Kܱ=6[4>��x�Fb;=_B����<l�D��=���9��(�����/�<]��=3��=�����H%>#���>��=�(��CӽWK��O�>�E$���׼����Lk=#r"<���<�k<�Z�������,�ѥ�=�s7>�c��(��;�5����=+C�;!��1-�q�=3C�=3���M���ȼ���=Lr<���i� > ���X��G�u<qk�=8�x�4t ��)>E�E��<�=e�;ԙF>�o�>0����W��t/��۾��+>����W�ƽ�#���������@��}��=T.��P����ӽVC%�dR_=]���w���ќ;�>��>�O���m=?YҼ�3�>l��m�=� �m���?h>Q=c�4��=�^���ɼ�w<�S���=
���G>.[�=��<��y��^j>7�����=�y;>S8�>-n�R
�=�Pw>j|��=�޽ue0�?;+=_ӟ��h��B/>�/�=�y=�F�=᣼(R�Ḇ=�x4���<�Sl�=F�#��ʽ���9�$�8�<F�r=�5)��>���a=�?>-j	�� Y<��H��)W=�%�=�>m�ཱུEٽ��>�*;���Ā���n�v]5>�⟾+9>s��%�=˙i=��W���=Ķ���8���4=%�!�0|�>X��=�	!>Jv>5HA<o
�=�����@>F��Wo>�����=��b>9<Z>�W��hLp;�� dн,}�<��*�
n4>�tŽ��=N���lbT���b=��"��2>�z���c��C�=jW�o>��%<ߡl>Ȇ"=���=�S�K�<�#+>Sb�=���=:�N�_�${< [
���.��A(<M��=sHk<_��=v���0�<mܔ�ȃ�<O��=�����2�=�>C=�uu�<j�м������9>o�<1S =wX>���=<�td���<�c�c���=	da;#�>�>�=�=��T<�oS�)q/>ޗ�>�f����6P��3�%���_>��=��e�ȱ>07>�*�<m�c>[9��Z���ݵ���ՙ=����F��tx.���S=��<��=ͩ�=8k>"��>��R>Oj4>���ؼ�r�<�uY�܃;>7 �2�ϼ�6 �?N��ʊ��(>;󳽟��=��Y�}�ƽ��S>5R�=���>��>��"<9'����=ň�=��_=�N�>�C<7�=��>Y"Ƚ¿`;�X���M��M�<���;/�P�Hǐ��������=�f[>��G�u�)�xv>�nͽ 'u=_s���X��j�	>�X�� ��qʁ=��=١����G�$����?G�=˪��]�>gˇ��c��/�=�;��ڤ���g	�i�2�?ýL�U>O�?��z=�C)�a7�d�"���^>��:���o�L�=O>�;��˟���^=2�ɾ`�<��y:��tS��o�=̀�<�B�N�<���=SV�=67��F�.�=>+)Y=O$?>�P�>&֤�J��<�`��%d=�:����
#=`�S�[���(>��h��R��R_�=Rv�>	�>bz0=36����=l{���dF>�����w�(>;81=�K�*2=���T���ǎn>����YS��j�<�Q<�^z�t��=���=f,m�o����=���N�J<�k���E��Y$��'�=$�����D]Q�>a�%��<M��=�H����-�!��<eJ�=�
#�<'޽]�=���k����<���]-Z�ͯ�<��>��a=�ג���,=������;XN��Y=]T7>��ּf��s
�>��q�Y��}M���<�x��=t��9K���,>o=�=�<ԽV�ɽY?<K'�y��;f��=�$>�c0��ƻ�L��9>���u�<�5�W>f�k<���>��z?P�>>��4�(�>��>`ʉ=�(�>���=>()�#��>Z��=�F�=q�>�1�=H�!=tw�>�l0<8��;�S���訕=���/9�=�K��;^���ͼ)�J;Ě����=T���%/��e���	)>�>�'��5<������:��>�6�|->��6���n<R4���T=�5
�[ �=R�h=��=�e����a�h�+�-�1˨���8�_w�/�[�7��S>_y�=���RB��*���H�཰�\���+�`���%-�k��0�=($��:��=6@G���L>ESE�>�����#���>�%
�|ߏ>���>�!N�'Y >���%�[=^��=�.����=���<)�K���>�}=���<-�=g��,f����9,B>�S?O+�=r�>�a>���o�1��=2�F�?졽͏}�X ��P�=A1��܎%=� ��=������a�غS��x�=���3wʽ��+���m<'AB�Nv�<;���7�=sg���,s=��J>�S�-�,�:gG�[?�Z�>="=�*!�3^��	�=�����+
�c��G�����/
�/۽�-0=��׽*	>�Fx��A��GԽ��"�-:u=�'�Jý=aQ��3�=���e�����p>`(�<��G��N����=�A��U�<9<�k��E�>rH��N<7��=C�+�9=�v)<+��>8y˾]J}��Ｚ�>*��et�=Ar������P�O����4��|����=C�=������>&ڙ���ܽY��� e��M��<I�\={��=����"žќ=�'��� �ȵ$���b�Q������7k�<M��=L1��y�N:�*J�<��E>�>�t��5�h�=�أ���L�V퀾��=ɖ">�=w�>=�x=��=:��#GI�O����������S�?�3;ޞ�4�n<-�&�����#��H=�U�=c�C�-�2>9Ќ���8>-_�	w;���<��=��,5��5�>�Я�ȷ��5+������z�=%�Ӿ��	>��>3=A=u�>A#o=a��=�������-��9��ܚ��L">���_�;H>��Y<��E>�M���޾b�'=�a���|��=8>¼�=^�	�>��ƾ��=�Y>����xQ�=�}t��p)=Tu7<\��"��y�2�xFH�<O�<�(����p���/<���cF���-�Hۻ<���g=���=�
r�3US>uă<�Y��U���Iۇ�Gl��~�=W6�@�_>����"�r=CZ�����=�2�=�s=��l�r%>1U�=�,��)O"�Xk1�H��=vp���f>���!b���=͡���8>%bB>�E���x�<ԑ�=�%>�5.������=Q�ǽCt��ξ>MO>�B��.|��=<~�=H[=;dP>h��=��	��u:�;��>�ģ�)s=t�=;Q_���>��D>b&��-��j�=��p��6ǽI�n��l
��h!�c��>�%��D}=���=:$W>YF���[
=uL6�\	�=}�4��T<�<�R9=�f=7�;����>�:�~>,!��ݪ�������н�Ǯ=�惾�Nm<��뻯1�#Žw�=�p���8�n,�>��a�J�=�C��3���N?�U5t���.>���;�>[�=s�齜�=�Z'�*dk��ـ�����
���u -<+_8�:4Z=(�����ǽ��:=+������=5��U��/W�=ω��W�=6�p��XM���@>n�>]Z�B�'�Ctk<��&=R��<��;��	\>��>����@�=��������:X�zܫ�JV>0��8��a��ٛ�=��=���=�R>䴱��m����=��[;�ҽ�F�=�B�=� ���	=ۍݽ6#4�T=�Q�3��=�?���=�4T>b�=���9�x*�����j��ў=�I�=�R���=X��3b=t����p�=�r\�è�=��=�Q�<4��=D��*��O	۽�Y �.�<wM=       �|?�'E?4�?��;?�K�?�A�?ϑ~?w��?�`?Qr�?7D�?5�?@?�?r�x?}��? /? v�?oI�?�+�?+rd?       4�9<#�r;ۤ(;�<<�~;U.�;���;D�9;�_g;�F;n��;n<�Y<��;$?�;�,~;,�:;��;�C�;$�H;       �             �O@��?S��?���?E��?��?�p�?*��?!�?.��?��?|�?lP�?�^�?Ô?�#??��?�`?��Y?ԥ�?       o�>�s?���?��>��?{5?L'?�9�>K��>��?s��>W ?��j?H_�>���>�v?J��>b�>�?="�>      x��B�����G>{����>QRY>p�!=N�>k��=�pV=��g>TA0�/��=(�a�%� ����9��-����=�"r>�}�<��<K��\L=]pD>e�=��C<(R�=i��qwG�ǿ���쉼���'�m
>%<��͗>�oս���=��*�o�J���x� �,�][7>67'�i��<��]e>f��t%��W\k�e�>N4S��2<�p}�=W�e�� ��!o==�T<Kn-�E^�)�>����`ɽ-�1���x=�VS=P�C>4粼�>�����=��� ���B�qN����=U5&>`½D���b>�
��;��c��dl��=t>��^�K���A���h=\0�[iҼ��m�I>����m�=�P=7����>������;�^Y$=�m>�.U�����-PW��0��W׺4�6=��=�^>w���_��hrB�h�=�j��ZP<�0,=&+�=��8>����V��]?:=����TܼK��<���=���=�#>:���;��� ;�Վ<�5��<��=^�=����;+�ή(��;>�u�q����˹���R�ˉ��o��R��>�=��=��>���=�K8��t=]p:��x=�o�=��8���>�Q��C?{=�;���<��\>h.�������=	����v�yUʽ�ν}F�=:�t='M����=���=)�,<&y���l7����;��y>B�S�$� �B�(�2�>E[�=k���=ঽ�N~>s1>�t�����Iq�=�)>ٕ)�y�r=�f=.�ŻHm�=~���^�h�>��=KI���)<��<���<k���E-��]
�y���O�=���n*R>6?��y+��3�=�0�m����>��o���(<���=E�%>�M��P�����+�b�0�=��L��_>-�S=B�*�����ʐ=m�ן۾�o>Gk>�O����=<�ս$޽���K�s�;�����>n��=:� ��Ĵ;B���>bs%��tK�a�8��=C��=���=����K����>�	�Fڧ��BH�� >�،>ܫ����e����8*�ʸ#>Ɠ�,��>�B�8�Z�J��0@�s6>�K�<gŇ�8�GW��4����O�s@>��<T�=o��<��K���<���=�1����)=��r=�ĽP�o����=0'����,)弑���"��=o�,>)�%>)>1>�^���F�2���|$>���=7'����*����<���E����<6�ϋ�}!�<�g��(U����a>b��du\��^c��E���)��L���r���o�k�ܽ��V<�g=��={���ۙ>ݦ�� ���=B;!��{�������.�q�M�߽,��;�)L�IA��L=�
w����;��=�Э><���Wf>�4�w褽au��˾�=m׭����
�A>��<.���f.��wZ���ǽ�����B=�H�<R�O`���<TW"�W6R>�#P���=��=����ߥ!�ij��6���F���+�'���L9>���=F[>=`�$�w�N��D���G׽1�y��=õ[>Yǩ=��	���j�
Y�Rݾ���BO���:rV=]���xg�(�u>�F^>�J)���X�7ܥ�M��;���=�(��p������A6�� ��=O���I�C�<��>�e���9ɽ�^�=g,=H�r�J�_�}�̼�ނ��@�=.Z��KX���eL>��=�9:�t���~�=l��<�-�=�� �L�G�4�>�=����-=;g�=*����=�"�<�m���M�<��=�V�3������!�>FϢ>w�6>���E)ؽ�w�=�H��j1ѽm��=��=R+�>���1�=�>�t�<���nb�=v���q�"��=u).>}�༨D�=	y%>A}9=����o=�;�M^ݻ,Ͻc�B�E�ؼqB���ȗ=\~ɽD����tD�'>�<, E>a�>��]���)�8�<𰽯���I�`��`����B{`>�����g>h���v�=xˮ9��3���<=f>���V-=m���Bþ��?>Z�3�Qa>K�!>,Ќ=��%r=�:5�%ѽ�@<*��<��<�6>f�K�`�K�Hd=�.��O���B=       �             �             ���?�ƾ?��?8��?�g�?�?���?4��?3��?=��?�[�?�O�?�.�?�[�?߷�?��?�L�?�f�?�=�?쉡?       �=���<�>�Sc�fp���e?q˃��r��4�i@俩���Z��'���굿����o�?G1n�=^!?(ڿW�*�        ��=qh���>U!l�G����оcl�>�̹<��ѽ{l����f��˩;�轀���OL:>����lu��}�i�<�b=;�V��n�>��/�[��י:�cbX����=�.}��p�-��>ܝ�<�K��<�=6��>cW�=���ޏ<�;$a=�T:>��'>�f�AZ�	�¾U$�=��o�n|�nC�=�>�6�={�=M-*>Z߅=�9>@~<�7�OU�6F�=p �C �=�=�6 ��A����=�1:��5>Z�I>w��=�׌���=�,>�a>�Io�*w�z�>>��M�R'�x�>��>�ch=X.���1>�O�=�?����>�(�=Ľ>z�����<?F>K�S<q��@fl=��*>HhC>ݮ;<�=�.e>��/<2��ה=�>��<Ɥ�Ö�=�.=#�>,��(U��X>��=��\�=�=j�=����=8�B=�t,>E��@u=�A�>i�]�[\��E \�ek�=:b�=����uZA=5����h=V��=��=0�=!EJ����=C���1=e.=7����$�-S�=]�Ͻ� <N��	;Oiq=�l-<Y�ڽ�?O=�?���l��+�>�W�=u���Q�����<zV�=��<=�O)�\c���6>>J�t��P��H=kJ�=<�N�����4=pc�=i8u� >�<U�ξED/=j��=?J��_�>D�j>!w=���6�>�����=�M��lw���v�d�J"�<�	�<�)Խ�E=�hQ>�gA>z�I���׭�=���=p�o=?��< W=�9��t�=~��>*�4��=��ݼ�l����k�0��=���=,�=�*I=,�=�T�=W�$;D3�L���\<b��I�A=��=���-{��˾��=g�L>[������>@C��3�%��@��3��>���T�I=u���>�������<��=�ӕ��k�>�H!�x>HeP=O>i� �t�=)n̼��=�7�����<��>�X��ٶ�3�����M/7���=)���6�����+
=Lڽ����0=��@>�Ɣ�՛ý;�>�g�;�Ŷ��=Ts���Uj�̲M�V��;2�>�u�;k�:������O	�>Y�4�s P�B��=��\��ZŽ>!��}��g��JW��N���W�<�!@>&�=AÓ=�$B>Y(C��(�=APh�_�����߻Dg��gw=��=JL��X2��*����᥽��.=��r����򊒽(p�=�'��Hm�=  ���e>:�=7~�<���>�R}>3�q=���=&g#>�<!å>	\��qJ?>拃�c�������;|,>
�V>�U��)aF=��[�h"=.�(�%=�;�=��=�j�2"���z>�MԺ� �>����`�ѳ#>��0�hC=�jD>��.�qڿ=%�U�/X�=�S���믻��">^a�>�h��٧�=&���l	2>����P���T>N���z>��=���� �<P�.=���Rf.=��	<f��" =cT2�qΕ��k=��C=�ж>seŽ�)�=����=����<�S��[�5�9�Չ�<a>+=�n*=�}Ž �R=wM>6H>瞽��>A	�=\��=�>'�~<<n�=��<��;��=Y�=U���,(��X�����<��=�>I8�<�o�=H��=�rH�`��!v�="��=�-=ɘW��?�=u��=E�O�����=&/��d];�t?"=�^=V�9���&����=���=��=ʦ�=}��LV@��m����w=	�#�N5�='K�=��3�O�>?u��[�;����>���=K#�=�x�=}-w<5��=N�����=�����l�=�a�5�׽6�ܽ���:�~<ZX�����\�����<��=vĈ<?b+>����P�I�= <L��=g�=�-�<c{�
Ì=|A����=�MS>B۽��^�H|��>= q>���=o����,�=�޽(�=��#=�ż��=��P$>[F���J �"w��]�=�ŋ=@��=����r5Q����`����lO=.��=g�%=���[����e�`�"=2��=�c�M�;8l=1>`=r��z�=��ӽRK��p�=��^�Ԣ>����}@=����6"�==1���O4��Q>t�->�=�<([��nAj�#�/<��ܽ��<N����S>��<�W���Kې>�C=I��=�,��@�=�O�=#�� �{=D����r=~S�=�)>�UO=�D>�x��7\2=��>�D=&p���)1>�$o�p��>�v���^���}��Z�<��O�'��=+����'&>�)���6�<��>���=nF=��=%��=��%�=kզ�UN�=���>=���;'�=H|�=��;w�.>]���!�;=Q��_Q=D��=�;}�Ww=�hT>� =㕶>�7C<��>��� ��َ=4�6>�\r���$�'��=���lB�=��/<�@�<s��=�e`��>��=Ld�<a�J>\eX����=������$>;Q��j*<iP>�>;�~?�=4��<m-�=L����?=�oR���>��¼V(�������}���Ѽ�6�<Ղf����=���=����D�aމ��*���F�=�V����Q>6����=�"�M��>O��f�M�Jἢ$g<��4�"�F>�&>3��^��7=�к���=���='�<kSѽ�>��,=Vh̼L��i�=ǻ|��=� >��(=�>�5�=�w�=7�ֽ���.��
�T�<�f��n��pý)2�<�d���:�=�gp>I��!�>���v��ܞ;�>4����UD=��W=�௼�tL=�
�= e�F��<˘�=���<@E=9s>u�=��e;��y=��E>���=B\�;L��=_i#>�[;>ǧ�����C>#ν5a�<�0�U��<9� >$ѝ=e1ϼ��d���l=%S>�Wy;�&Ż���>u��>?�o=�s��~<-�ދ�=�s���bB=���=����ᓿ=m�x���=]��i����;�{>;,@=�>I�9>^�0�<J=b��%�{�+�$��7=UX�;h8>�m.�O����=���� ��J�>�>$��>׀��tH�d�꽴�P=ؗ%=�}�=��~<2��<�f��eW�=
>�g�=�� �t� ���L�M�����ؼb�<�c0��:=����#�ƽr��=�.^��������)>I�\�'�2:�O��_U�=�>��0�l��k�>T��<�>�=�0����=��=�ʤ=�|����;�4�<+ǿ<t5^<W�=WL��z�=)\�=��=����]�%�{폽G�<`Y�<������y�;��<��I��*�Hj�=]�=݅��E��=(�&���{��㼽[�C>��>��=6��;� ��ؼM�ڼeoY��V;���/���v�z�>Gw�=���>SY����?=]�>Sꐺ,�O>L��,��=�#$�tmM>ۻ�=��<�[�= .�=��(>��=�%l��So���%>���<����DU=�p�=Ow�<������g��=��=M�>\+��j�o>^Z�>n���	�=�_L=]S�=�Ӊ�4ɉ��<�m0�I��&��њ�N�O<�򦽖���(�<��>s�2�U)�=j���c��T<�\_�m��=�=K����t�����6�=AV>)u^����a{:7����8
��k���= �Ƚ�#9�j=Gjﻈ�D�|4�1>z=�0��4i>_0e=�N=��">NoA=l�(>�=s�<��=!=���=!�g=���A��=��<.��<����N>�����2�����AI<�z��&��/8�=��i�z�����<�Ԅ�A���F^=-����-�j^��i�=�㲽�Y�<��G=�i<��ҽ�w����;����p�j�&��?�(=�!�=:!,��Fz=C+�NC�=���j�*����;���2�^��.򽟙���((=丂=E�=��F�8%=��=#Ƣ��ȼ<�~�W�f����g��c��l$���o:X�=����r�=+�<����fg�F�����6��I��`��=�
�FŽ�m��v����/;�M�����[�o=�}��5c/=䡌=z��Mǽ����OQ�=/�O�qLX=V��=�-��2=2��=O���=�[�;�w>�S=��#>��O<�ƽ88>	c>�1>JK�<�$>�~�=|��>ю=t����F�=��;�5<Q��=��.�@<r%�=Uf�=B.�=ff�=vB��6����Ż�>�t��ҽPЉ<��=[[�=�A�;�uo����=cpD=%��=�=|p=�Y;�T`�x�>� ν���<�)�<VW>�t�=_�.=��o����=�\��Ly>2L�0���=6�E�ѝ����=��<����z&>2Pv=�o�=��/>�J��=���=��F�8���������x>�
��T">���<�<>�h��Fl>�F��hHF=��ɼ�{�QQ�ޟ��� ;=��+>;꾴 �w^q����4H�0t�.�ξ�>����E��ˠ��t�;� �=R�>�>:C��,�=� �;�XP�_\�<	m\�5i ���w��;Q}=:>_�K'Z=K��=�>ܧV<��|���>~�(=��=�Y�<I꽾Le>W�p��Xy>~�\>�yt>= ɾj�5�.CU=�m->�����>��<�j�=N�)>��=·$>��¼Զ���	q��0�=��4�K��=(P�=��>5t�<�F�i:=�!9>`�1=����й��P̽�_�<���c�S>?�ƽ���S�x5��3��￼�)��y���I㷽!>�������>�K���}�c[�=�ﱽ���Ua��9sB��>��޽^���������>�� ���=Io鼓�F>�����p5>����h=3�SR�<��2:���=tŽj�m>W�>��<������Fy�O��=���x%<a�H=7 =��6�½�L�É�=�7d�9?h>�-��sK��o�1�
>R�	�x�c>`"Ͻ�Ȑ�Ϙ ��װ;BԶ���x>�k��V
>`��w>�@A<�on=艆��'�vc=Vnp������O���¾��>���&p�<����6W=ɍ۾����%UO��ɛ��I�=�m��w���I����<��ѽI�Ž�Q�>�xӻi'�|��=F��=���R�=�j��Ö=J�A����=,	=x���Xْ=/�$>�TX>��<j�v���;�<��
=�/=2����==ܛ�=��i=DA��	�=���=D��=@]0������.1���7���>q�5�*��=���שB���=��D+>lv!��}W>T؄��*�=�T>�>���>i�v���ܽ�"�>9�c���K>ϯ=�=�9мt�x>^j�<�x�<7���"�g=n<>(�%>�A��h[=��Z>B9�=�V��mqj��A`=t7>�ׅ�����=�1�>[߹��2B�
RB>vY=$f��Oq=�ͼ
}����O�)����#>d8�=��=�5����2�>�>��)<v��yw�=�t�=�S��V�8�$�Z�H�f���u��]5>N[%>3e��-��1>�ai>$o��6FJ�����>�=�������=�>e�=�`�=�F�D�&=Hc׽����2�N�s>^�5<S��{=�e{��\>n�?=�S2=~��=�<B��L�#?>�{U=W�>Y�=;[�<_s���O=��=��=s{Z>��<���=yS=���=��>f��>A��=b7>^00��"�>g�=@>C �=���>���9p�H���@�2L��zO��5�=�*�=���h���C�Wʟ=X<�= >��� ��= @ >�q=
�=Lʽ��>׀�=D2=�ǘ=���1=�>=!=�>H�->ƣ���Y�G��(w<dW�����<��<�T����;�̴��x����2���R�2
/:��I>t|u�J�6��o5��(�=�[>����8>��=��j��2R=}F=���=���=�1����=� �<��q<i�6>��<A=�́=�@3>�r=�V���S>u�>ϐ6=��>�,>�@[>��>H�=Y��=����U�,>:��U��'�=�q�<���=��>�d<)ƍ=!9H>i�>:��<�/ӽSB-��/>�>��Y=x�=㿽���޼7=�R@�#x^>��=	�̽5�=��>����/o=�dN�h�=�=X�#>��.=,�>�O�=��::��>�М��D�=�>��>���<��<�e!�d�'>��=�^b��@c���6;��=]۽2��=-��>��d����d�
=��=� ��H��=��{���<���=�>q��	8=�Ղ=̋ ><�廎�L>��h��r�=�Co<�%�=D��<ނ >�`��p�=�`�>�!�=����L*�����Y���D)��γ<7�8�Ж=�����qɾ��F�k�c=!d��9�>�t�<�^1>m����z۽W���vi>�>0�?>����c�Q>/��<��<C�)=΃佺af���#=�j8>�t�[�K�������>׆=�5G��=ҽA>G�����3�w�w>UŘ�m]�=Y:b�3�;h���c=M>���op>�٠�s�ѽ��8>y�=ku���\8=gUۼ�q>�Oe�.�>=�>�z]=*a��� =��T=�\�W�*=�n�=�zD�]�k�'+��l�B���E��-�<<��=�K2��>���y=�ܪ���{=X��^�=�k���}Ͻ!�&>=>�{q�U�����t�3>Yʇ�*^���ֽ��z>���=���X����JB�S��k�/=Sg�-���j�h=u_H����=wY�>|m���{�[��>]7�=Nҽ��.����<�i��dн���<_�</ >g�R=����p��<�L�<9R�m���Ƥv<��>�2ͼ��=�-�<��/��'�=/��<�#�:
��ݠ�y��$r�=/�5>Q9`��P�=Gp���cI��	p�e�d=3�D�O�$>e攼@�<s�Y��}ɽ1��=�\���D;'�>�ܠ=�r�=�X>�L�o=��WC>bg>)G��:@7��EK=:p��f���0��p��I�=�/=z�~=��6�X��:Y�ͼ��={�D;�<�	��2>�jX=J>A^�>X;���9�}�&�=aE��J'=dq<�B���=����E� ��<��=�)>:db�GK�="�8��9Ľ*a��o���9>lK��=}�l����u>.�=��;>_?���>IU=����{>�ű�ی"��Ƽ?ý��?�s��?+�<gh�:};�>Y}=%)�C��f�.>M'��ӯ�=��<�W�=��>�ӽ��
>D��>d�H=��H>� >��Ͻ�'���ǔ=�L��X<t�����=�H�=���������=�O�=�u*>�":;���=�OE>q� �'Gͼ=��;���=�����Ҋ����=ȸ)>��= ��;�������=5l%>*���s�9��D]>��S=�������A���|>.L����f�#=�w�=������-���=!`�>r>[�E�}j�<��0>�>e�Z���W���=��=�-��S+�=r�D<�N�=���=}?l=�|�>gQ�<� =�����>��o�D��=Xm�<�/_�LW2=8Џ<���=l�V���ʽr(����=T�==g��= ���^����W>
Z>,��Mgs=W��<+�;L���;"�=��O*���>��ؘ߽�=�M��e��n �=�M���D=Sͻ��as���}�6�<Ȃ/=,�`>Ja<����U-��	�R�Ya>Q�$=��X�K�G>~7��َ=�#�P9>x�=�Np>)v>H��=(����2�V��={�;� �={�F�pq���sn�����폾:�l��<N�>J��=MK�=��"��~�<�<��c�N���*>�������PŃ=���-,1�
�c=�d>Z�>۽�<�<�m�����ɽf�>"�ƽ�@=��½sh=�>nK��*Ӫ=�˖=�O;�� = ��^t%>!��=*/��v�ͤ>p�<_�E��%���mr=n���g��z�J=(��=�;=�)�<��+��w7>(�=����)}�=�u0>Tbe�/�S��\����UY�=}���\/�_V>XAu=���=�����/��Ec=&�ԸгĽVTc��=@M=��\���-=M:��«F�a��=���=���;_�=`���NF�=��=�䛻5҉<%��=�>�)�=˽<
W���z<ũm�U/@>�"�<t��=���=��=�����5�w�O�woֹ�ã����=�������jcn����yx+>��=p����g�T���LA��n%����P�2��ԭ�\�=sB��C-����o���>Bf�=��޼�½��>�6ͻ�]��|\H=^|>D�'>�A�>��w�~�ٽ��=O'<�c[�R\)<�.<�q�<$�:��Ρ����=���=V�	>O@�E�>�i�AB_��Lf>EY?>H}�='�����=n'�����WTE��_�>k�<>�S>i��=)�P� S>��N>����h>�����h�=Ѥ彦DE>��>G�-<x��=�@>�-;>@T�=m��) >[)-����;�^�֣j=���rY���a�2�$���=��a�tJ�v����)T=�����0>B(m>D?A>d�->p��?>�K�=�pi>��>0�=���=��ý/q���i3�?7?=Kn�>ū���n߽Մ�)žP]�a�	=�F�=�RB����
�>¦w��8$=�Q��ea�= c>�p=��*=;�=���=>�<��z=u�:=�@{=��<��\=VD>8�,=r.=s-�=�@�=�iG>b{>7�v�~;!�Y}<�l�]�=�l>�J'<S8>&�J�rL=�j=[=�=���=yZ�=�"��(��l_Ƚ�:8���n>6@D��>�~�'��>5,�<��.>��
=�	e=g%�=9�����<�q�=�>Us>�#�=�g=t�C>�9Q=�#>�PV<9�:=�����7��WQ>@���!>����|�->��U���~�b�=��=q�%���>�f�=�6>�Oҽ|�q�Ua< �ս�Ik>���=�T�=�nQ>bi�>�M_=9��=�Cy��:�=�	�=�白�L��]*7�?@>�X�<�I�=fx�=��q��������=�<"s�=�<�S������R��<Q�=�[>���z+>c�=�>cѽ��p�}{'��7�.�F��S>�!=p���/�{=6"�����<�!��_v�0�f=i�5�^?=K]%��-<�D��=��E>:�k=�ѽܿk�]Ϛ=wbq��D=�����<W�=Ц2>�Q6��/���7(>G`!��0̾��7���)���n�NKU>���<��I�)��=GaǾ��������Y��>C{�/��=��<�5E���}�»>��$����=�'��ᶴ�S��=����a�>���>a��<�a1�B���=�2�>bٽXF�> Ƥ���#>.5��\1��hs=��R=>��Ԃֽ�.t<���װ����=W��<A�>ׇ�={;�=�>΃�=�ȝ;�_�=�և=u!�y�=�����.>�+b;�����h�=}�/>3ċ�1e�=hp�<9�`=�o켕0���4�=��>7�=���hX>�2�=6��=(h>H���}|�<~!G=�����/��9��*gn=�۽F�=�n<ҏ �tr����=�>�8�:�/ ��f���=��;m��Ţ�=?�=6�c����=�:�-�����=D�P=��=9D/>a�@>��"=���=9���%�=���y��=|!���<{��<n� �h�,�6.7=B��/�ȼ��>��׽�E�+7�����=9�ν��>��=mMڽ�	>9��=dD����Ⱥu=A>�#[�j3ؽ�ǀ=Q�F>��?>-�]=Vf=3z���B
>"���&����=���=�;0=��-����;kc|<�����7��1�=^�<6h�f->[�l�y �=	��,��=Ct�=+���+"�e�:>B�[��;�u�=��V<Q>�ߍ=�]h='&�K��=���=�� =��<U,���M��v&=sT��;��u��#��p>�ٮ=�q�e���
>&��<�bt<��=�a�=��<xd����<�n��>���=��F� >��"���>�qJ��]>������
�8]n���
>	��<`گ=�QL�I�/;��->/��R��+L<�>�6>`��=�L����d�<�D/>-���ɑ�=�>��l���}=ڇ��>�=TW��FE�Yg�=�9x�;�F�T�f<��>yAW>W*$=�Ś�v&U=t�<��l>���=����)>)�6�*��ܛ�i��=�+�����<J->��9>Sֽ+z�8��<g�/�#=%��K|$<C&>o��Ã>�^>��ȹ������ѾZ'>��E��;��/��=��i�ֱ&>R>��>,Á=7𻼔	=&����0�=��A>�轊7�>�=T�A=�T>��=�Ԗ�u8��ͽ�/c��:�i�н�<i���x�b�t��X��Jh���v���S��y��;J��>9�ν��s=-�!����<^]0��u��-8���ts=.A=�s��S�u=�Y�=[-�L�o��L��A����o��Ŀ����I�%��y��E_f�K�0>#�x���\�*I�0b��a�>x����!�p�>��㽫;���	�"a!>u=p=���=���=�(��D���W�cPW�G�4>�?�kiĻ��z�bW\��* =���D̽�u�p+��X8����a�&�J�<���`M꼶�=����iV=Z|�<yB��r�<�v�=+��
i�%��y-=Y��5��<C����\�=OV�=�;k����<�=W�=�e㺵�9=�#��vv=�ջ�`�=:�Z=��$>�H��Ш,�����+�?#��!坾<��"$>�W�=��R=[I��ڌ=[F����=��$<i�=�I<��m�Ƥi�~�e=k��<>�ѻ�<}= �t>X�*><�>o�����2�<7��Z�=�ȴ�P�6=���D*��Ve=E���Dub�ߋ�=(��������N�<Р׽�%=����~~=*�?=R�>{�ý��=�['=Y�>ٯ�=��,=���#�4��>hz�O�,���B�K�%�(R*�f�U=�NN��<M���==�=^&�=���<l�	�=��;>θ/>��,>(��=}}]<�$��ν6�t>�֢=O8�|�=���g���#�a ����=(���3+�z�ҽ�&�<�><?R���=���=v����Y�F�.��<�-�=��<>vVO=0K�=e�:m�>y����=���R�=P�ܽ�쓽�4�V�<-�"�d�	=��<v}(�-��窺��W>�Ad�+�>jD�<�}���>4>2��=�.������}=�p<^r
>��=\��=E�Y=�Խ�r����?>��ڼ-t-�R퍾
��=R����+I��O�=���tXB�3Q��X�R�'���d���Aķ�W6��h<��%Ä9Q�5�wP��� R����=y�h�� ���6�vD>�܊<�� >9f�P�D�E59��Y�;Q�l�5.�<	1>{�;>�?5>�٤�/�X�t�d�����|D����=�,J��-9��>���3-���k��o+[<�I�=�ս}S��g����F̽}q�=[���J�3��1�ġ�=O�7��x`�dŀ��[��S��:���=x�?>,?��|�>�b<<��E���=O`>�->q�)��R>�W>捷;ߚ�=R@�=VM�>,��LI�(�/�=�V��㨽`u8��RͼF�|=N��3ķ=߿��f�=���),>(�E=S��=J��c!�R���1-#=vWm�a�T=�-�=
�=�/��9p�B�5���>D�����!�����,
��)=1��=7�~�m��=���������%A"> ׭=by�=&�#�����#���0@�m�O>.��<�Y�=� =k>m��J]��)�Z�;=�Tq�Q!�=Vi>���=��=�=��<��{�v3;�r�< ���xY���`|=�L�<�-�ɤ��	bx>�R���
>�k��(�> g�=L��	w>�}>�_��B�>���21���s���&<2<O��^a>NZ�?.e��[����=�<�x��>d���<bf>�<���"Ҿ%�[���=aT�cN�`W�[|����9��&=�����l���<�U��jc����L�w��=��p�Y۷<���<w��Ͻ5�Z=�+�>#�$�pt��� ���h>=Hi�e�d��9��[k��-$R=���=\>��=Q0�}�=|�=�f���<֊8>ޮ>X�>����o'�.�=�=�]�=[���ﻸE�=���=�t�=G+;>'a;T$=~����ƣ=�I�=p�=\�ؽ�9K=�&�f�=��z=�s�<=�-�������=#;Y=�95��P=���=hw�����=l((�0ڻ=���>����/!���<�C>����kq=m�Ͻ=��<�����>[>��½e_!����=��Y���[<�ZӼ`�n�vG佔�e=�� ;Rΐ<J<h���=��@�>O	���܄=��<�<���EY�9$��<�-�=������N=;:0>��=C��JM1��7�%��>�f =�5�=�[%=gK=��&����y>TT�=ʿ�=w>/��y�F�.>����gx�<Lì<�4ܽ9������=I/o=?�>�Ho<H��=5z��{,=�z���P�=5�󼉆��K&�#�J>�����f=3;W��=�>7�þ	Ҹ���*>�7=D�=�5?>����Y�^�~��`�;�&�����=��.9��6��|�>�>�(�=�X�<�9�=�a�=e�=nF�=�W>Ǫ=��=.%o��t�=�2=X!�T��;�;>%�9��������j{m��>*R1>z��<*�>�93>�: ��6��O�=��ھX\���\��a�=2�d=�~�R{C>}�{��i�;�S_>�.�9��=Nw>���=М�>`:�!I�>ͼm��|�=2�=1uC=�!>Ⱦb�=�<�y��>�q��ˡ�=���!�5=Z=/JD�8$S��t��As>�F�=�=��`��>�6�==C̽�E>[�=F��)>�͘���=_S��K蒻,��7+|>���5�����O=�Ǯ��ԙ=�ۣ=������>:G�>K�<k���@����Z��A�_ga>ۑ1>���%o?>Y 齂�>�����t���H$<��U<���=�׼�	��^0�=-����f=���=�]߾4=�/V�u�=���ޟg=��=��<���<TgO�E�
�"�->�����|>���v=�������<Ц)���.�!��<���>��>�7�(>�VE>�)�=�	����=��>]�>��?��o�=�*�=�k���~���{��d>���<����3
>ס>��I�]��J�<���=��>q�4���s=p�=6�Z<�ؽ�0H>�b�<��;���>���.�>��;����}�=���<�Wz<VD�<!r��(�=�=�) >^|�=Y���w��3���Ľ�ñ=8�C>\'�=������a��=�ͽ;1��R�8=�PM>�\����-�â*����=U��=ʻ&<V�Y=��{���ۼ�)P<'+}=�	�맻@��8�6���޼=#?<�}��a��=���nI�����P�=D��;��[��=�>=cZ��a�}����=�9�>�.���0��0��r>��=�@��z��=5!�>2�w= J�u�[�7�<�τ��}н�@ν㮼j�=�L��D߽�Yb=��f<��.�/]=ey>�
�[z��>홾eL>����&�������Nr>� >�X>����oý����7
�=@*������۷�>��A�v��=�J½��>�2=n�=Fҽ<��y��=��<�g=��%��S�=r+>����q4=�X���߷��=>��*>��==U�->�A-=��>6M<���<�y���1�<jS=M��=��=��V=8�,��!0�@hp>�؝=L<xz�=e�"�یO�~Ѩ�ŢX���z=�+>�L��S��=�q >��=9�=⽷��_�=S=������!�=yFU��w#;yE5>��>�$4<vF7<&Νb>/7���V=���=ŭ���7>��?>��I���T=�Լ���=�9��
������j�=D߽G �<���>\�]>��=ڻ}={㫻}��=�>��o=��C=S�Ҽ�ν�?�7�~.>�߽*�¼}��<�د��G׾�8i��3�� 4��bDI�`��=�l�P��=��=���=t�X�R}=$��������<���=(˽3;�<#�B���<.<<=�h/><��<y����b�=��>�� >rJ=>5=\�L=��= 3ֽ�_�t=x�mN�=��>A��=��ƽ��=��z=�:��?܊��8�R��殱���y�m&ֽ7�>h���3�Xw?<Z�5-�;<���V�`=S����>�CD<���=J��XC�=R](��é=�̼��0=p#��m�x2o��L�=3�0�a>���=$��=�J7�ix��.��M�#������r>VR��Ȝ�=j ̽�>G�t<��=�D:����"/��W��r�;�.=H���v|e���>�%���Y�t�=�F�=���<&b��S��~��=Ѕ>]�;�k��=��<��M����L����A%>L
^��	"�[��<lc>���<��>�Æ	<K�i>�3>�n�����>
-=i��s��쮚>�r>T=�	M�o��=��>��=Ѣ#�l� >�<�=��=&�=,_�=���<���=#l�<_����G'�8�e����׻�>y����T����&�="�=>�=�A�=�A�r3:�ݔ���<ߊ:="Z�=:R��P1>@�> wq=�̂���=�-��Ok+��#6��*a=�p�=)޹o1>#^1>�7=g�=l�=�>��W>W*�̓�=F�J��AA>ѷ�=(@�=Í�=�X>i�=��=���=&���|���5#F�
j�=���<[����=�>�<�S=M���HI=��X><�μ�0����ͼO����9>d�A��=��;�8a�8�="���nx��jn�>m�R>~t�=��ǋ�����<pk��3$#<~f��5ߕ=�Vݼ��F=��=���=V/�=Sv�=T�7>�!�;s��;��ʼ�Ul��A�=|���J8ܽx�=��>">yv�=�Ļ��az<Z�ͼ��<avI��=%�=
d���=�,|><������=�>����4 w>Ⓤ�-�>���گ4�{0��J��=���=K;��y���پ`�>x6�>V���pn`>g9�<��#>P�;��=��ý]Sr>�Dվ��	<�g��i9=�Ź=��>{O���+������E=�:j<�{�=~��tn�>�h,>r�����>J���<>4���2�9>����F=Qj˽��=�>��	�\�=;�>�r<���=���=	�
��>ik�>^�6��O�=�=!�?�}�{�䮆���w����=z��<є���>�s�=&�l���޽�N���&�����v��d<�'R>�-������F��!S>�T�Q��c����'>;B�=������=�
����JE�=��<�(ӻ���<�!�=��+=���>�c
>@}=�gR=���;5K���cN>[2��ˑ��Y>��;>N�ý��?sS�-/��'׼r��<���= K=��J;��=d?��>�f¼.,>ba�=��ݽ~J�<U��=�ׅ�W���$>B��>i-j=�E^�W>c� >Gl5>�ۻ�����+f���,=�5:��t=-Z>��8�zs5=d�-=�x�=<�0������>9��	7�=21��t(�;��=���=�),>��=�p�2r=?��yj�>=ŭ=��Խ�E9���W>���� �=:��J
\= �Ѿ�Ė=Iσ����[-�skȼ.��G0	;��=~Q��3�>]1>��=�߽v(M>[�=1�]=�S#<�ؽ!w�<�+U>&O`�^+J���>㬊�)1��
�H��!r��������V��=�|>Sy�0Ӳ>��V�a�)�n�=�
Q��za�M�=<���Z�<�ݐ=����s.�=h_X>Wu^�I��8��>_(N=?Rp����P&���f� ����>r$M>v�<�%=D)�<�\�p��c޼m<r���=rт=�<��2
?������g�4�=�Љ�TJ|���ͽ��~����=:P=ʅO�
:P>q�>��.5#�/�$�M��<󵫾|=B��=��ƾ�a���`H:�ct=	�Ծ٢@�����Ѫ۾(�=��Ҿ����b�=��������2>g>�_=t4���{����>�F7��!>_�d��o���� rʾ�:�m�>���=-m�=?�=�!����=���=�88�� v=]}�>P�5i�2�ݼyʫ=c_����T�֫�>إj=Y�v=D�r��ʔ>6���:��>5k��*rf�/}[=�k��O*<�u#>�K�=)>8=m%>�<���n�+=�"۽�W���%�)>�����.���G>u!�����=�u��Uv�QM��)�<�K.��>����Wֽ2����>שֽY����6��x���g��!<��>IaC>>櫽E>��>���=�����ӾT�� />����������6�=K��B�*4��c�=�dؽ®����>��=U�1=D�۽
,��� �=�a��� 1<�(�gqd=�9��Md=e�b�+>�U��;~�=��=��F���l> 1~=��
>���|<=q>�k�=��	�&���R�#���j�b��A>�w��Q>�c��t�@>��z�w�>�܂�Lߍ�?�p���q��ś��9н���=���pYF�l+5�(�=3O�p�D��⽼a�<�������~��K�͗8=ޘW���<�@������&�<�>z�=`3=�E>>#@�=CŐ��,������&NŽ)\a��I >�{>w�=W��<����!->-le��v(>e��f�=ab@��=i�&��>���O�0>���k�=Y%��cZQ�^���:��=��y>r�[=|�=�=m��>c��>�(k���=���<"�6�j�8��;�ʥ�T�#>kN=g>(�-=��>p+�����������=�h����>[��\E4=zͽ�o�� Ἥꇾ_ڝ�m���{B��V�=�a��&jz��++�p��ч������_R�1lѾ�	i�k��>ø�磢>����Յ=%�B=���>���ԋm=^6�=�<">�tg��/����)��KI��D˼iV=fæ�Hk�>�7�L+�<��5=*��� 5d��~,�tN"=	���(�`�T>cN|�'�>�z��?�y�kR,>d���q�>�PԽ��>	o��\O���{>O+>�QH��z><�x�C�<ZL���f>ܤ�JSs>
F�=��=w�G>"�:<v+>n�P>�A=9">AϞ�0�=S�P=���<�۔��t����Ƚ�v�F�h�(�&� ���/��Z��ʶ�=˔ξ���=D��|�,=v�;��Y�=�f�=l�o>&�ȽI�8>�+��a�=6Ov=�('>a�U���{��5i=�˅���o���>�C��������fɟ; L�����,4���&��t�F�,����;HJ�=D�;�⩽C�>+'6>��=e���O�
>l�}>�P9>��o�<�����P=��2>e�}���ƽ�с�c�5��W3=de���w���*=7hĽ�}|=L7-�*ܗ=�3�� �u��r�2��q=ân<v\=Ԟ�>�k���0��Č����=�Xི<=ׅ�=�X#>���=���<��/�
�>��7=��6>%�=�#^<��=:(=ƁO>�0='xR�Ԃ��a7�=W��=@Q=����9c!�|q�>ծ=����Q�M�5�չH?����|Z����.>��<R����&=5�s=�=�g�%�>T=zýۣ�<Yzf<N{׽޲����=��Y:�y��&q���>"yL>M��>�-�����<�y��D>�Mp<��<�
>�	
�TV���i=)�>$�h>�⦼k�!S6=��=�˅�L�;�K޽��*�)�m���s=(&><��=0�g=�{�>�v,=Y�=
�4����k�>$�=E����	��� >��<�09�n���ǣ=�P=�(��r��<����̲���c~=���=�+��T=�������t=+"�=st��Z1I>��#��1�=�Ӓ<���W�c�+L��&��x����z�� �=d�+�Z�d>[�=j�����t=��=�*�=m��=:�ýI�8�d�d=hs���3<�������=mh�F�?��≾�-��kRʾ���=�pK=�W�8>�!-��\�	~m�����e2s>���:,�8=�-p�:�I>��>�(&���>-���{g�<�;T�Am׽�<�<���h"��*��PX�ݍ��6���$�<W�?�<i"�"f���+潢h�>�����/��<՗j=�ك=u���#=�.��k�;��e=vJw�XY��E��=��=����%x<k	�J ���'�Y��	�w=Bz��K�����L,�;�=������=:������o�Z�<����&�-�<�"��@������_E=������/a�d5���Y=lە=6XU�b��I���Y�N�B�[�"��� :�K����<��	��'�5�m;�0<��g=�����"��h���Y޼���=�E�=���<{�_<"���C���==u0Ǽt>g�=<��?=&�>:������t�G��᡼#j�='S[�xYӼ)B�=��=4A���0>;GG��y�=R�ʻq/�=	¼�Lh���C��r��x|�<�s�<(Y=���x��=�J=�>��@�1=��=�\>�����p���+>�#=�]C>�g�=��>�ԏ�,B>��<���<uN۽�䰽}�������/g��P����o��`�$��<������=�W��M	� I%=`7��:�<�=��f���=��J�����C����c��o��8�_<;��ü������
��y1���K��ڽ� ּ�*ý�����܅�<5�#��*=to�� 좽�|X:�`��QY�B=~��=#	M=������=CB�R�<w���цz={e=Ĭ��Cؼ�-�;�x��b�<�E��ߌ½�]k=/B��k��t����<���z0��ڍ=�����=��S=�����g=
�)��7��d$���|���>/���U��W|L�AD����,P��z���H���m=����ϲ=�z0<|���Y~=C��<JA+�� P�@}�;�a��'m={��5������9�[�"��|콂>�=���=��>� o>��xn�=��E>�E>�o��0�=�3�=B>����YV��rt>��6>h��2�����>%v>��~�'���p����b����th�;�9L>�Q>Ps�=0��#:>���2(=%�5��񋽼����»6�$>FNq=�ô=��;���=�=��=��=O�o�@�>�V-<��V��λ<3�< �=����Z�=���=����T��<�~X����=�ɒ�lT�����=y��=��>b>��h�2>u��$�6�0r�='Z<�`>���=����S�=����9��;����S�A>j��<�r1�]��=w���ר�;�*��D�=���n>	��/ɕ=�K;���=�ƹ����=�4w��&�<���= s�Q8�>76=�R�n�>����L�>��<�D��=�!<��=@@>���=�"�<+ꊽ�jn=+�=�繽�?��z�ʽ�>��3>�YF>�`��;�>�}��嬾r�'�K��Q>��!�fV0>Ch�=�H�=^��T`=|-��圽DT!=�m(����=k��=8UL�h�����=��*�;��=��+>X$�>�J�=�/>������
�􃞾��[���A=��>
�<>k�=8���&�X=���="\�=E<����巁=�.=�
� �YĽ��=9�S�ĉ佘E~=�4����=�hĽ��p?��Ε=$�<x2�<��<1讽d�h��^�����(���R�s�gZW��Έ�����=��?�i(��	9��h�Ƚ�ֽ]�<qQ �6��
OV=�
�[�F=�&D=Э�x����>�nS��G�=1F����7����=����۶�(��=������S8?=�&�=l�%�ڂ������@=aڈ<P0ͻ�-E� ��=U�<��;��۽���"��bҲ<�ȣ�#���LS�;��=\e�����@�=$��<��ͼ�ƽ}���JC#=       �>`i=��,�/�<���=���>v�.�h�>}b>�? ���V=��m�ļ�:�>�Bֽ��+>Y��;�	>���=�5>